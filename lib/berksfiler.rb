require 'pathname'
require 'configurability'

require 'berksfiler/formatter'
require 'berksfiler/generator'

# Berksfiler programmatically generates Berksfiles with correct dependencies
module Berksfiler
  extend Configurability

  CONFIG_FILE = Pathname('.berksfiler.yml').expand_path

  EXCLUDED_DIRS_REGEX = /^\./  # reject . and .. directories when globbing the cookbooks dir

  CONFIG_DEFAULTS = {
    cookbooks_root: 'cookbooks',
    nonstandard_cookbooks: [],
    common_cookbooks: [],
    excluded_cookbooks: []
  }

  def self::cookbooks_root
    Pathname(config.cookbooks_root).expand_path
  end

  def self::nonstandard_cookbooks
    config.nonstandard_cookbooks
  end

  def self::common_cookbooks
    config.common_cookbooks
  end

  def self::excluded_cookbooks
    config.excluded_cookbooks
  end

  ### Get the loaded config (a Configurability::Config object)
  def self::config
    Configurability.loaded_config
  end

  ### Load the specified +config_file+ and install the config in all objects with Configurability
  def self::load_config(config_file = nil)
    config_file ||= CONFIG_FILE
    config = Configurability::Config.load(config_file, CONFIG_DEFAULTS)
    config.install
  end

  # returns an array of all local cookbooks (basically a directory listing of the cookbook_root)
  def self::local_cookbooks
    @local_cookbooks ||= Dir.entries(cookbooks_root).reject { |dir| dir =~ EXCLUDED_DIRS_REGEX }
  end

  # returns an array of all cookbooks that are not sourced from the community site
  def self::non_community_cookbooks
    local_cookbooks + nonstandard_cookbooks.map { |cb| cb['name'] }
  end

  # Generate a berksfile and place it in a +cookbook+
  def self::emplace_berksfile(cookbook)
    puts "Generating Berksfile for local cookbook '#{cookbook}'"
    content = Generator.generate_berksfile(cookbook)
    open(File.join(cookbooks_root, cookbook, 'Berksfile'), 'w') do |f|
      f << content
    end
  end

  # for all local cookbooks, excluding `excluded_cookbooks`, calculate all dependencies
  # and programmatically generate a Berksfile for that cookbook which takes into account
  # the correct sources for all dependencies.
  def self::run
    local_cookbooks - excluded_cookbooks.each do |cb|
      emplace_berksfile(cb)
    end
  end
end

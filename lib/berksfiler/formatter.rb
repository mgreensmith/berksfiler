module Berksfiler
  # Methods for formatting data to be emplaced in a Berksfile
  class Formatter
    # generate the correct Berksfile line for any cookbook
    def self::cookbook_line(cookbook)
      return special_cookbook_lines[cookbook] if special_cookbook_lines.key?(cookbook)
      community_cookbook_line(cookbook)
    end

    # generate a berksfile line for a cookbook with explicit options
    def self::nonstandard_cookbook_line(cookbook, options)
      "cookbook '#{cookbook}', #{options}\n"
    end

    # generate a berksfile line for a community cookbook
    def self::community_cookbook_line(cookbook)
      "cookbook '#{cookbook}'\n"
    end

    # generate a berksfile line for a local cookbook (within cookbook_root)
    def self::local_cookbook_line(cookbook)
      "cookbook '#{cookbook}', path: '../#{cookbook}'\n"
    end

    # a hash of 'name' => '[formatted Berksfile line]' for all non-community cookbooks
    def self::special_cookbook_lines
      @special_cookbook_lines ||= generate_special_cookbook_lines
    end

    # generate a hash of 'name' => '[formatted Berksfile line]' for all cookbooks that
    # have any provided options or path specification
    def self::generate_special_cookbook_lines
      out = {}
      # local cookbooks are discovered from coobooks_root, and are just string names
      Berksfiler.local_cookbooks.map { |b| out[b] = local_cookbook_line(b) }
      # nonstandard cookbooks are always provided as a hash with name: and options: keys
      Berksfiler.nonstandard_cookbooks.each { |cb| out[cb['name']] = nonstandard_cookbook_line(cb['name'], cb['options']) }
      # We accept an arroy of strings OR hashes for common cookbooks, since they may or may not have options.
      # We only need to add the hash-type cookbooks, as the `cookbook_line` method will fall back on
      # the default `community_cookbook_line` formatter if the cookbook isn't found in this hash.
      Berksfiler.common_cookbooks.each do |cb|
          out[cb['name']] = nonstandard_cookbook_line(cb['name'], cb['options']) if cb.is_a?(Hash)
      end
      out
    end

    #### DISPLAY HELPERS

    # given a 2-dimensional array +lists+, return an array of the maximum length of the
    # content for each index of the inner arrays
    def self::array_maxes(lists)
      lists.reduce([]) do |maxes, list|
        list.each_with_index do |value, index|
          maxes[index] = [(maxes[index] || 0), value.to_s.length].max
        end
        maxes
      end
    end

    # given a 2-dimensional array +lists+, right-pad each array member based on the
    # maximum length of array members at that inner array index
    # returns an array of formatted lines
    def self::aligned_print(lists)
      out = []
      maxes = array_maxes(lists)
      lists.each do |list|
        line = ''
        list.each_with_index do |value, index|
          line << "#{value.to_s.ljust(maxes[index])} "
        end
        out << line.strip
      end
      out
    end
  end
end

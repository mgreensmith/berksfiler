module Berksfiler
  # Methods for formatting data to be emplaced in a Berksfile
  class Formatter
    # generate the correct Berksfile line for any cookbook
    def self::cookbook_line(cookbook)
      if special_cookbook_lines.key?(cookbook)
        special_cookbook_lines[cookbook]
      else
        "cookbook '#{cookbook}'\n"
      end
    end

    # generate a hash of 'name' => '[formatted Berksfile line]' for all local
    # cookbooks and cookbooks that have specified options
    def self::special_cookbook_lines
      return @special_cookbook_lines if @special_cookbook_lines

      @special_cookbook_lines = {}

      # local cookbooks are discovered from coobooks_root, and are string names
      Berksfiler.local_cookbooks.map do |cb|
        @special_cookbook_lines[cb] = "cookbook '#{cb}', path: '../#{cb}'\n"
      end

      # cookbooks with options are provided as a hash
      # with name: and options: keys
      Berksfiler.cookbook_options.each do |cb|
        @special_cookbook_lines[cb['name']] =
          "cookbook '#{cb['name']}', #{cb['options']}\n"
      end
      @special_cookbook_lines
    end

    #### DISPLAY HELPERS

    # given a 2-dimensional array +lists+, return an array of the maximum
    # length of the content for each index of the inner arrays
    def self::array_maxes(lists)
      lists.reduce([]) do |maxes, list| # rubocop:disable Style/EachWithObject
        list.each_with_index do |value, index|
          maxes[index] = [(maxes[index] || 0), value.to_s.length].max
        end
        maxes
      end
    end

    # given a 2-dimensional array +lists+, right-pad each array member based on
    # the maximum length of array members at that inner array index
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

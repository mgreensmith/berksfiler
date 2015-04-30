module Berksfiler
  class Formatter

    # generate a berksfile line for a community cookbook
    def self::community_cookbook_line(cookbook)
      "cookbook '#{cookbook}'\n"
    end

    # generate a berksfile line for a git-sourced cookbook
    def self::git_cookbook_line(cookbook)
      "cookbook '#{cookbook}', git: '#{@git_cookbook_urls[cookbook]}'\n" #TODO: fix @ ref
    end

    # generate a berksfile line for a local path-sourced cookbook
    def self::path_cookbook_line(cookbook)
      "cookbook '#{cookbook}', path: '../#{cookbook}'\n"
    end

    # generate a berksfile line for a cookbook by determining the correct source
    def self::cookbook_line(cookbook) #TODO: fix all tehse source vars
      if @git_cookbooks.include?(cookbook)
      git_cookbook_line(cookbook)
      elsif @local_cookbooks.include?(cookbook)
      path_cookbook_line(cookbook)
      else
      community_cookbook_line(cookbook)
      end
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
          line << "#{value.to_s.ljust(maxes[index])}"
        end
        out << line.strip
      end
      out
    end

  end
end
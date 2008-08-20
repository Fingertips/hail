module Hail
  class Repository
    attr_accessor :directory, :location
    
    def initialize(options={})
      options.assert_valid_keys(:directory, :location)
      @directory = options[:directory]
      @location = options[:location]
    end
    
    def scm
      unless scm = self.class.recognize_scm(directory)
        needs_location!('recognize the scm type without a working directory')
        scm = location.ends_with?('git') ? 'git' : 'svn'
      end
      scm
    end
    
    def get
      needs_location!('fetch a working directory')
      needs_directory!('create a new working directory')
      
      case scm
      when 'git'
        execute "git clone #{location} #{directory}"
      when 'svn'
        execute "svn checkout #{location} #{directory}"
      end
    end
    
    def update
      needs_directory!('update a working directory')
      
      case scm
      when 'git'
        execute "cd #{directory}; git pull --rebase"
      when 'svn'
        execute "cd #{directory}; svn update"
      end
    end
    
    def needs_directory!(perform_action)
      raise ArgumentError, "You have to specify a directory in order to #{perform_action}." if directory.blank?
    end
    
    def needs_location!(perform_action)
      raise ArgumentError, "You have to specify a location in order to #{perform_action}." if location.blank?
    end
    
    def execute(command)
      system(command)
    end
    
    def self.recognize_scm(directory)
      return nil if directory.nil?
      if File.exist?(File.join(directory, '.git'))
        'git'
      elsif File.exist?(File.join(directory, '.svn'))
        'svn'
      end
    end
  end
end
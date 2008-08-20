module Hail
  class Repository
    attr_accessor :directory, :location
    
    def initialize(options={})
      @directory = options[:directory]
      @location = options[:location]
    end
    
    def scm
      unless scm = self.class.recognize_scm(directory)
        scm = location.ends_with?('git') ? 'git' : 'svn'
      end
      scm
    end
    
    def get
      case scm
      when 'git'
        execute "git clone #{location} #{directory}"
      when 'svn'
        execute "svn checkout #{location} #{directory}"
      end
    end
    
    def update
      case scm
      when 'git'
        execute "cd #{directory}; git pull --rebase"
      when 'svn'
        execute "cd #{directory}; svn update"
      end
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
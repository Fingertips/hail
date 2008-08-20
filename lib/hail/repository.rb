module Hail
  class Repository
    attr_accessor :directory
    
    def initialize(options={})
      @directory = options[:directory]
    end
    
    def scm
      self.class.recognize_scm(directory)
    end
    
    def self.recognize_scm(directory)
      if File.exist?(File.join(directory, '.git'))
        'git'
      elsif File.exist?(File.join(directory, '.svn'))
        'svn'
      end
    end
  end
end
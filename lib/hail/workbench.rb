require 'tmpdir'
require 'fileutils'

module Hail
  class Workbench
    attr_accessor :name, :directory
    
    def initialize(options={})
      @name = options[:name]
      if options[:directory]
        @directory = File.join(self.class.expand_path(options[:directory]), @name)
      end
    end
    
    def directory
      @directory || File.join(self.class.basedir, name)
    end
    
    def ensure_directory
      FileUtils.mkdir_p(directory)
    end
    
    def self.init(options={})
      workbench = new(options)
      workbench.ensure_directory
      workbench
    end
    
    def self.basedir
      @basedir || Dir.pwd
    end
    
    def self.basedir=(dir)
      @basedir = dir
    end
    
    def self.expand_path(path)
      return basedir if path.nil?
      File.expand_path(path, basedir)
    end
  end
end
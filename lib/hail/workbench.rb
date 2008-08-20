require 'tmpdir'
require 'fileutils'

module Hail
  class Workbench
    attr_accessor :name
    
    def initialize(options={})
      @name = options[:name]
    end
    
    def directory
      File.join(self.class.basedir, name)
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
      @basedir || Dir.tmpdir
    end
    
    def self.basedir=(dir)
      @basedir = dir
    end
  end
end
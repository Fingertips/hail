require 'tmpdir'
require 'fileutils'

module Hail
  class Workbench
    attr_accessor :name, :directory, :original, :clone
    
    def initialize(options={})
      @name = options[:name]
      @directory = self.class.expand_path(
        if options[:directory]
          options[:directory]
        elsif @name
          @name
        end
      )
      @original = options[:original]
      @clone = options[:clone]
    end
    
    def directory
      @directory || File.join(self.class.basedir, name)
    end
    
    def ensure_directory
      FileUtils.mkdir_p(directory)
    end
    
    def config_file
      File.join(directory, 'config.yml')
    end
    
    def write_configuration
      File.open(config_file, 'w') do |file|
        file.write(to_hash.to_yaml)
      end
    end
    
    def to_hash
      {'original' => original, 'clone' => clone}
    end
    
    def self.init(options={})
      workbench = new(options)
      workbench.ensure_directory
      workbench.write_configuration
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
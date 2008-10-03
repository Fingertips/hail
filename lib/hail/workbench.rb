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
      @original = Repository.new(:location => options[:original], :directory => File.join(directory, 'original'))
      @clone = Repository.new(:location => options[:clone], :directory => File.join(directory, 'clone'))
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
    
    def read_configuration
      config = YAML.load_file(config_file)
      original.location = config['original']
      clone.location = config['clone']
    end
    
    def write_configuration
      File.open(config_file, 'w') do |file|
        file.write(to_hash.to_yaml)
      end
    end
    
    def to_hash
      {'original' => original.location, 'clone' => clone.location}
    end
    
    def get_repositories
      original.get
      clone.get
    end
    
    def update_repositories
      original.update
      clone.update
    end
    
    def sync_repositories
      execute "rsync -av --delete --exclude-from='#{excludes_filename}' #{original.directory}/ #{clone.directory}"
    end
    
    def put_clone
      clone.put("Updated to #{original.revision}.")
    end
    
    def excludes_filename
      File.join(::Hail::APP_ROOT, 'data', 'excludes')
    end
    
    def execute(command)
      system(command)
    end
    
    def init
      ensure_directory
      write_configuration
      get_repositories
      sync_repositories
      put_clone
    end
    
    def update
      read_configuration
      update_repositories
      sync_repositories
      put_clone
    end
    
    def self.init(options={})
      workbench = new(options)
      workbench.init
      workbench
    end
    
    def self.update(options={})
      workbench = new(options)
      workbench.update
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
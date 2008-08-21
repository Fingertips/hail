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
        scm = location.ends_with?('git') ? 'git' : 'svn' if location
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
        execute_in_directory "git pull --rebase"
      when 'svn'
        execute_in_directory "svn update"
      end
    end
    
    def put(commit_message='')
      needs_directory!('commit changes')
      
      case scm
      when 'git'
        unless File.exist?(File.join(directory, '.git', 'config'))
          execute_in_directory "git init"
          execute_in_directory "git remote add origin #{location}"
        end
        execute_in_directory "git add ."
        execute_in_directory "git commit -a -v -m '#{commit_message}'; git push origin master"
      when 'svn'
        execute_in_directory "svn add `svn status | grep -e \"^\?\" | cut -c 8-`"
        execute_in_directory "for file in `svn status | grep -e \"^\!\" | cut -c 8-`; do svn remove --force '$file' &> /dev/null done"
        execute_in_directory "svn commit -m '#{commit_message}'"
      end
    end
    
    def revision
      if directory or location
        case scm
        when 'git'
          begin
            lastlog = execute_in_directory "git log -n 1 --no-color --pretty=oneline"
            lastlog.strip.split(' ').first
          rescue NoMethodError
            nil
          end
        when 'svn'
          begin
            lastlog = execute_in_directory "svn log -r HEAD"
            lastlog.strip.split("\n")[1].split(' ').first[1..-1]
          rescue NoMethodError
            nil
          end
        end
      end
    end
    
    def needs_directory!(perform_action)
      raise ArgumentError, "You have to specify a directory in order to #{perform_action}." if directory.blank?
    end
    
    def needs_location!(perform_action)
      raise ArgumentError, "You have to specify a location in order to #{perform_action}." if location.blank?
    end
    
    def execute(command)
      `#{command}`
    end
    
    def execute_in_directory(command)
      execute "cd #{directory}; #{command}"
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
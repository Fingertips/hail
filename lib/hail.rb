require 'rubygems' rescue LoadError

require 'active_support'
require 'optparse'

require 'hail/workbench'
require 'hail/repository'

module Hail
  VERSION = '0.6.0'
  APP_ROOT = File.expand_path('../../', __FILE__)
  
  def self.run_command(options={})
    command = options.delete(:command)
    rest    = options.delete(:rest)
    
    if command == 'init'
      unless rest.blank?
        options[:original] = rest.shift
        options[:clone] = rest.shift
        options[:directory] = rest.shift
      end
      Workbench.init(options)
    elsif command == 'update'
      unless rest.blank?
        options[:directory] = rest.shift
      end
      Workbench.update(options)
    elsif command.blank?
      puts "Please specify a command"
    end
  end
  
  def self.run(args)
    options = {}
    opts = OptionParser.new do |opts|
      opts.banner = "Usage: hail [options] init <repository1> <respository2> [workbench-directory]\n" +
      "       hail [options] update"
      opts.separator ""
      
      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        options[:verbose] = v
      end
      
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
      
      opts.on_tail("--version", "Show version") do
        puts "Hail #{Hail::VERSION}"
        exit
      end
    end
    opts.parse!(args)
    
    options[:command] = args.shift unless args.empty?
    options[:rest] = args unless args.empty?
    
    unless run_command(options)
      exit -1
    end
     
    options
  end
end
require 'rubygems' rescue LoadError

require 'active_support'
require 'optparse'

require 'hail/workbench'

module Hail
  VERSION = '0.6.0'
  
  def self.run_command(options={})
    if options[:command] == 'init'
      Workbench.init(options)
    end
  end
  
  def self.run(args)
    options = {}
    opts = OptionParser.new do |opts|
      opts.banner = 'Usage: hail [options] <command> [repository1] [respository2]'
      
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
    
    unless run_command(options)
      exit -1
    end
    
    options
  end
end
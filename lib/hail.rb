require 'optparse'

module Hail
  VERSION = '0.6.0'
  
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
    options
  end
end
require 'rubygems' rescue LoadError

require 'bacon'
require 'mocha'

$:.unshift(File.expand_path('../lib', __FILE__))

require 'receptor'

module StdOutReceptor
  def capturing_stdout
    original_stdout = $stdout
    $stdout = Receptor.instance
    yield
  ensure
    $stdout = original_stdout
  end
  
  def stdout_lines
    Receptor.instance.message.map { |call| call[1] }
  end
end

$:.unshift(File.expand_path('../../lib', __FILE__))
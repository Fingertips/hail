TEST_ROOT = File.expand_path('../', __FILE__)

require 'rubygems' rescue LoadError

require 'test/spec'
require 'mocha'

$:.unshift(File.expand_path('../lib', __FILE__))
$:.unshift(File.expand_path('../../lib', __FILE__))

require 'hail'

Hail::Workbench.basedir = File.join(TEST_ROOT, 'tmp')
require File.expand_path('../helper.rb', __FILE__)

require 'hail'

require 'receptor'
require 'stdout_receptor'

describe "Hail, invoked from the commandline" do
  include StdOutReceptor
  
  before do
    Receptor.instance.messages.clear
    Hail.stubs(:run_command).returns(true)
  end
  
  it "should switch to verbose mode" do
    options = Hail.run(['--verbose'])
    options[:verbose].should.be true
  end
  
  it "should show a help message" do
    Hail.stubs(:exit)
    capturing_stdout do
      Hail.run(['-h'])
    end
    stdout_lines.first.should =~ /Usage:/
  end
  
  it "should show her current version" do
    Hail.stubs(:exit)
    capturing_stdout do
      Hail.run(['--version'])
    end
    stdout_lines.first.should =~ /Hail [\d\.]+/
  end
  
  it "should exit with a negative code when running into a problem" do
    Hail.stubs(:run_command).returns(false)
    Hail.expects(:exit).with(-1)
    Hail.run([]).should == {}
  end
end

describe "Hail, when running a command" do
  it "should initialize a new Workbench on init" do
    options = {:command => 'init'}
    Hail::Workbench.expects(:init).with(options)
    Hail.run_command(options)
  end
end
require File.expand_path('../helper.rb', __FILE__)
require 'hail'

describe "Hail" do
  extend StdOutReceptor
  
  before do
    Receptor.instance.messages.clear
  end
  
  it "should switch to verbose mode" do
    options = Hail.run(['--verbose'])
    options[:verbose].should.be.true
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
end
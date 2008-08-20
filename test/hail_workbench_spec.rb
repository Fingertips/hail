require File.expand_path('../helper.rb', __FILE__)

describe "Workbench" do
  after do
    FileUtils.rm_rf(Hail::Workbench.basedir)
  end
  
  it "should allow configuration of the basedir" do
    old_value = Hail::Workbench.basedir
    
    Hail::Workbench.basedir = '/tmp/basedir'
    Hail::Workbench.basedir.should == '/tmp/basedir'
    
    Hail::Workbench.basedir = old_value
  end
  
  it "should initialize a new workbench on disk" do
    workbench = Hail::Workbench.init(:name => 'hail')
    File.exist?(workbench.directory).should == true
    File.exist?(workbench.config_file).should == true
  end
  
  it "should expand path expressions properly" do
    Hail::Workbench.expand_path(nil).should == Hail::Workbench.basedir
    Hail::Workbench.expand_path('.').should == Hail::Workbench.basedir
    Hail::Workbench.expand_path('~').should == File.expand_path('~')
    Hail::Workbench.expand_path('/tmp').should == File.expand_path('/tmp')
    Hail::Workbench.expand_path('hail/one').should == File.join(Hail::Workbench.basedir, 'hail/one')
  end
end

describe "A Workbench" do
  before do
    @workbench = Hail::Workbench.new :name => 'hail'
  end
  
  after do
    FileUtils.rm_rf(Hail::Workbench.basedir)
  end
  
  it "should know it's own directory" do
    @workbench.directory.should.start_with Hail::Workbench.basedir
    @workbench.directory.should.end_with @workbench.name
  end
  
  it "should be able to create it's own directory" do
    File.exist?(@workbench.directory).should == false
    @workbench.ensure_directory
    File.exist?(@workbench.directory).should == true
  end
  
  it "should prefer a provided directory over the default directory" do
    @workbench.directory = '/var/lib/hail/myproject'
    @workbench.directory.should == '/var/lib/hail/myproject'
  end
  
  it "should switch back to the default directory when the provided directory is nil" do
    @workbench.directory = nil
    @workbench.directory.should.start_with(Hail::Workbench.basedir)
  end
  
  it "should know it's own configuration file" do
    @workbench.config_file.should.start_with(@workbench.directory)
    @workbench.config_file.should.end_with('config.yml')
  end
  
  it "should be able to write it's configuration file" do
    @workbench.ensure_directory
    File.exist?(@workbench.config_file).should == false
    @workbench.write_configuration
    File.size(@workbench.config_file).should > 0
  end
  
  it "should have a configuration hash" do
    @workbench.to_hash.should.not.be.empty
  end
end
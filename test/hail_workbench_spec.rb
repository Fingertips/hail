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
    workbench = Hail::Workbench.init(:name => 'hail', :original => 'git://github.com/Fingertips/hail.git', :clone => 'https://fngtps.com/svn/hail/trunk')
    File.exist?(workbench.directory).should == true
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
end
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
  
  it "should expand path expressions properly" do
    Hail::Workbench.expand_path(nil).should == Hail::Workbench.basedir
    Hail::Workbench.expand_path('.').should == Hail::Workbench.basedir
    Hail::Workbench.expand_path('~').should == File.expand_path('~')
    Hail::Workbench.expand_path('/tmp').should == File.expand_path('/tmp')
    Hail::Workbench.expand_path('hail/one').should == File.join(Hail::Workbench.basedir, 'hail/one')
  end
  
  it "should initialize a new workbench on disk" do
    Hail::Workbench.any_instance.expects(:init)
    workbench = Hail::Workbench.init(:name => 'hail', :original => 'git://github.com/Fingertips/hail.git', :clone => 'https://fngtps.com/svn/hail/trunk')
    workbench.should.be.kind_of?(Hail::Workbench)
  end
  
  it "should update a workbench" do
    Hail::Workbench.any_instance.expects(:update)
    workbench = Hail::Workbench.update(:directory => File.join(TEST_ROOT, 'repositories'))
    workbench.should.be.kind_of?(Hail::Workbench)
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
  
  it "should get repositories" do
    @workbench.original.expects(:get)
    @workbench.clone.expects(:get)
    @workbench.get_repositories
  end
  
  it "should update repositories" do
    @workbench.original.expects(:update)
    @workbench.clone.expects(:update)
    @workbench.update_repositories
  end
  
  it "should sync repositories" do
    @workbench.expects(:execute).with("rsync -av --exclude-from='#{@workbench.excludes_filename}' #{@workbench.original.directory}/ #{@workbench.clone.directory}")
    @workbench.sync_repositories
  end
  
  it "should put the clone (commit)" do
    @workbench.clone.expects(:put).with("Updated to #{@workbench.original.revision}.")
    @workbench.put_clone
  end
  
  it "should know where the file with rsync excludes are" do
    @workbench.excludes_filename.should.start_with(Hail::APP_ROOT)
    @workbench.excludes_filename.should.end_with('excludes')
    File.exists?(@workbench.excludes_filename).should == true
  end
  
  it "should read it's configuration" do
    config = {'original' => 'git://github.com/Fingertips/hail.git', 'clone' => 'https://fngtps.com/svn/hail/trunk'}
    YAML.expects(:load_file).with(@workbench.config_file).returns(config)
    
    @workbench.read_configuration
    
    @workbench.original.should.be.kind_of(Hail::Repository)
    @workbench.clone.should.be.kind_of(Hail::Repository)
    
    @workbench.original.location.should == config['original']
    @workbench.clone.location.should == config['clone']
  end
  
  it "should init" do
    @workbench.expects(:ensure_directory)
    @workbench.expects(:write_configuration)
    @workbench.expects(:get_repositories)
    @workbench.expects(:sync_repositories)
    @workbench.expects(:put_clone)
    @workbench.init
  end
  
  it "should update" do
    @workbench.expects(:read_configuration)
    @workbench.expects(:update_repositories)
    @workbench.expects(:sync_repositories)
    @workbench.expects(:put_clone)
    @workbench.update
  end
end
require File.expand_path('../helper.rb', __FILE__)

describe "Repository" do
  it "should recognize git repositories" do
    Hail::Repository.recognize_scm(File.join(TEST_ROOT, 'repositories', 'original')).should == 'git'
  end
  
  it "should recognize svn repositories" do
    Hail::Repository.recognize_scm(File.join(TEST_ROOT, 'repositories', 'clone')).should == 'svn'
  end
  
  it "should know that it doesn't recognize other repositories" do
    Hail::Repository.recognize_scm(File.join(TEST_ROOT, 'repositories')).should.be.nil
  end
end

describe "A Git Repository" do
  before do
    @repository = Hail::Repository.new(:directory => File.join(TEST_ROOT, 'repositories', 'original'), :location => 'https://fngtps.com/svn/hail/trunk')
  end
  
  it "should have 'git' as scm" do
    @repository.scm.should == 'git'
  end
  
  it "should get a new version of itself" do
    @repository.expects(:execute).with("git clone #{@repository.location} #{@repository.directory}")
    @repository.get
  end
  
  it "should update itself" do
    @repository.expects(:execute).with("cd #{@repository.directory}; git pull --rebase")
    @repository.update
  end
end

describe "An Subversion Repository" do
  before do
    @repository = Hail::Repository.new(:directory => File.join(TEST_ROOT, 'repositories', 'clone'), :location => 'git://github.com/Fingertips/hail.git')
  end
  
  it "should have 'svn' as scm" do
    @repository.scm.should == 'svn'
  end
  
  it "should get a new version of itself" do
    @repository.expects(:execute).with("cd #{@repository.directory}; svn update")
    @repository.update
  end
end
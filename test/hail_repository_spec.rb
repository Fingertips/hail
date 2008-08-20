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
    @repository = Hail::Repository.new(:directory => File.join(TEST_ROOT, 'repositories', 'original'))
  end
  
  it "should have 'git' as scm" do
    @repository.scm.should == 'git'
  end
end

describe "An Subversion Repository" do
  before do
    @repository = Hail::Repository.new(:directory => File.join(TEST_ROOT, 'repositories', 'clone'))
  end
  
  it "should have 'svn' as scm" do
    @repository.scm.should == 'svn'
  end
end
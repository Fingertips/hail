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

describe "A Repository that isn't initialized yet" do
  it "should recognize the scm" do
    Hail::Repository.new(:location => 'git://github.com/Fingertips/hail.git').scm.should == 'git'
    Hail::Repository.new(:location => 'https://fngtps.com/svn/hail/trunk').scm.should == 'svn'
  end
  
  it "should not have a revision yet" do
    Hail::Repository.new.revision.should.be nil
    Hail::Repository.new(:directory => File.join(TEST_ROOT, 'repositories')).revision.should.be nil
  end
end

describe "A Git Repository" do
  before do
    @repository = Hail::Repository.new(:directory => File.join(TEST_ROOT, 'repositories', 'original'), :location => 'git://github.com/Fingertips/hail.git')
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
  
  it "should put (commit) itself" do
    message = 'Pushing changes.'
    @repository.expects(:execute).with("cd #{@repository.directory}; git commit -a -v -m '#{message}'; git push origin master")
    @repository.put(message)
  end
  
  it "should know the current revision" do
    @repository.expects(:execute).returns("b264a3c8836311974620d7be7a8edca1730027bb Show an actual working command in the README.")
    @repository.revision.should == 'b264a3c8836311974620d7be7a8edca1730027bb'
  end
  
  it "should deal with strange output while detemining the revision" do
    @repository.expects(:execute).returns("\n\n")
    @repository.revision.should.be nil
  end
end

describe "An Subversion Repository" do
  before do
    @repository = Hail::Repository.new(:directory => File.join(TEST_ROOT, 'repositories', 'clone'), :location => 'https://fngtps.com/svn/hail/trunk')
  end
  
  it "should have 'svn' as scm" do
    @repository.scm.should == 'svn'
  end
  
  it "should get a new version of itself" do
    @repository.expects(:execute).with("cd #{@repository.directory}; svn update")
    @repository.update
  end
  
  it "should put (commit) itself" do
    message = 'Pushing changes.'
    # TODO: Find a way to test for three separate executes
    @repository.expects(:execute).times(3)
    @repository.put(message)
  end
  
  it "should know the current revision" do
    @repository.expects(:execute).returns("------------------------------------------------------------------------
    r450 | eloy | 2008-08-21 11:38:20 +0200 (Thu, 21 Aug 2008) | 1 line

    Updated links on new artist enjoyment page.
    ------------------------------------------------------------------------
    ")
    @repository.revision.should == '450'
  end
  
  it "should deal with strange output while detemining the revision" do
    @repository.expects(:execute).returns("\n\n")
    @repository.revision.should.be nil
  end
end
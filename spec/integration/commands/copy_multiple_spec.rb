require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Copy command multiple local files to remote" do
  

  before(:each) do
    @hp_svc = Connection.instance.storage
    @container = 'mult_from_local'
    purge_container(@container)
    Connection.instance.storage.put_container(@container)
  end

  context "when remote container" do
    it "should report success" do
      rsp = cptr("copy spec/fixtures/files/Matryoshka/Putin/Medvedev.txt spec/fixtures/files/Matryoshka/Putin/Vladimir.txt :#{@container}")
      rsp.stderr.should eql("")
      rsp.stdout.should eql("Copied spec/fixtures/files/Matryoshka/Putin/Medvedev.txt => :#{@container}\nCopied spec/fixtures/files/Matryoshka/Putin/Vladimir.txt => :#{@container}\n")
      rsp.exit_status.should be_exit(:success)
      ContainerHelper.list(@container).should eq("Medvedev.txt,Vladimir.txt")
    end
  end

  context "when remote directory" do
    it "should report success" do
      rsp = cptr("copy spec/fixtures/files/Matryoshka/Putin/Medvedev.txt spec/fixtures/files/Matryoshka/Putin/Vladimir.txt :#{@container}/subdir/")
      rsp.stderr.should eql("")
      rsp.stdout.should eql("Copied spec/fixtures/files/Matryoshka/Putin/Medvedev.txt => :#{@container}/subdir/\nCopied spec/fixtures/files/Matryoshka/Putin/Vladimir.txt => :#{@container}/subdir/\n")
      rsp.exit_status.should be_exit(:success)
      ContainerHelper.list(@container).should eq("subdir/Medvedev.txt,subdir/Vladimir.txt")
    end
  end

  context "when remote object" do
    it "should report failure" do
      rsp = cptr("copy spec/fixtures/files/Matryoshka/Putin/Medvedev.txt spec/fixtures/files/Matryoshka/Putin/Vladimir.txt :#{@container}/someobject")
      rsp.stderr.should eql("The destination ':#{@container}/someobject' for multiple files must be a directory or container\n")
      rsp.stdout.should eql("")
      rsp.exit_status.should be_exit(:general_error)
      ContainerHelper.list(@container).should eq("")
    end
  end
end

describe "Copy command multiple remote files to local" do

  before(:all) do
    @container = 'mult_from_remote'
    purge_container(@container)
    Connection.instance.storage.put_container(@container)
    rsp = cptr("copy spec/fixtures/files/Matryoshka :#{@container}")
    rsp.exit_status.should be_exit(:success)
    @directory = 'spec/tmp/multiple/'
  end

  before(:each) do
    @hp_svc = Connection.instance.storage
    FileUtils.rm_rf(@directory)
    Dir.mkdir(@directory)
  end

  context "when local directory" do
    it "should report success" do
      rsp = cptr("copy :#{@container}/Matryoshka/Putin/Medvedev.txt :#{@container}/Matryoshka/Putin/Vladimir.txt #{@directory}")
      rsp.stderr.should eql("")
      rsp.stdout.should eql("Copied :#{@container}/Matryoshka/Putin/Medvedev.txt => #{@directory}\nCopied :#{@container}/Matryoshka/Putin/Vladimir.txt => #{@directory}\n")
      rsp.exit_status.should be_exit(:success)
      DirectoryHelper.list(@directory).should eq("Medvedev.txt,Vladimir.txt")
    end
  end

  context "when local directory and regular expression" do
    it "should report success" do
      rsp = cptr("copy :#{@container}/Matryoshka/Putin/[a-zA-Z]*.txt #{@directory}")
      rsp.stderr.should eql("")
      rsp.stdout.should eql("Copied :mult_from_remote/Matryoshka/Putin/[a-zA-Z]*.txt => #{@directory}\n")
      rsp.exit_status.should be_exit(:success)
      DirectoryHelper.list(@directory).should eq("Medvedev.txt,Vladimir.txt")
    end
  end

  context "when local file and regular expression" do
    it "should report failure" do
      rsp = cptr("copy :#{@container}/Matryoshka/Putin/[a-zA-Z]*.txt #{@directory}file")
      rsp.stderr.should eql("Invalid target for directory/multi-file copy 'spec/tmp/multiple/file'.\n")
      rsp.stdout.should eql("")
      rsp.exit_status.should be_exit(:incorrect_usage)
      DirectoryHelper.list(@directory).should eq("")
    end
  end

  context "when local file" do
    it "should report failure" do
      rsp = cptr("copy :#{@container}/Matryoshka/Putin/Medvedev.txt :#{@container}/Matryoshka/Putin/Vladimir.txt #{@directory}/file")
      rsp.stderr.should eql("The destination '#{@directory}/file' for multiple files must be a directory or container\n")
      rsp.stdout.should eql("")
      rsp.exit_status.should be_exit(:general_error)
      DirectoryHelper.list(@directory).should eq("")
    end
  end

  context "No matches for regular expression" do
    it "should report failure" do
      rsp = cptr("copy :#{@container}/Matryoshka/Putin/bogus*.txt #{@directory}")
      rsp.stderr.should eql("No files found matching source 'Matryoshka/Putin/bogus*.txt'\n")
      rsp.stdout.should eql("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "Multiple copy clone" do
    before(:each) do
      @dest = 'mult_clone_remote'
      purge_container(@dest)
      Connection.instance.storage.put_container(@dest)
    end

    it "should report success" do
      rsp = cptr("copy :#{@container}/Matryoshka/Putin/Yeltsin/Gorbachev/.*txt :#{@dest}")
      rsp.stderr.should eql("")
      rsp.stdout.should eql("Copied :mult_from_remote/Matryoshka/Putin/Yeltsin/Gorbachev/.*txt => :mult_clone_remote\n")
      rsp.exit_status.should be_exit(:success)
      ContainerHelper.list(@dest).should eq("Andropov.txt,Chernenko.txt,Mikhail.txt")
    end
  end

  context "Multiple copy clone" do
    before(:each) do
      @dest = 'mult_clone_remote'
      purge_container(@dest)
      Connection.instance.storage.put_container(@dest)
    end

    it "should report success" do
      rsp = cptr("copy :#{@container}/Matryoshka/Putin/Yeltsin/Gorbachev/Andropov.txt :#{@container}/Matryoshka/Putin/Yeltsin/Gorbachev/Chernenko.txt :#{@dest}")
      rsp.stderr.should eql("")
      rsp.stdout.should eql("Copied :mult_from_remote/Matryoshka/Putin/Yeltsin/Gorbachev/Andropov.txt => :mult_clone_remote\nCopied :mult_from_remote/Matryoshka/Putin/Yeltsin/Gorbachev/Chernenko.txt => :mult_clone_remote\n")
      rsp.exit_status.should be_exit(:success)
      ContainerHelper.list(@dest).should eq("Andropov.txt,Chernenko.txt")
    end
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Move command" do
  
  before(:all) do
    cptr("containers:remove -f :move_source_container :move_target_container")
    cptr("containers:add -f :move_source_container :move_target_container")
    rsp = cptr("copy spec/fixtures/files/Matryoshka/Putin/ :move_source_container")
    rsp.stderr.should eq("")
    @localdir = 'spec/tmp/move/'
    FileUtils.rm_f(@localdir) if File.exists?(@localdir)
    FileUtils.mkdir_p(@localdir)
  end
  
  context "when source container can't be found" do
    it "should display error message" do
      rsp = cptr("move :missing_container/missing_file :missing_container/new/my_file")
      rsp.stderr.should eq("Cannot find container ':missing_container'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end
  
  context "when source file can't be found" do
    it "should display error message" do
      rsp = cptr("move :move_source_container/missing_file :move_target_container/new/my_file")
      rsp.stderr.should eq("No files found matching source 'missing_file'\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end
  
  context "when target container can't be found" do
    it "should display error message" do
      rsp = cptr("move :move_source_container/Putin/Yeltsin/Gorbachev/Mikhail.txt :missing_container/new/my_file")

      rsp.stderr.should eq("Cannot find container ':missing_container'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end
  
  context "successful container to container" do
    it "should have created new object at destination" do
      rsp = cptr("move :move_source_container/Putin/Yeltsin/Boris.txt :move_target_container")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Moved :move_source_container/Putin/Yeltsin/Boris.txt => :move_target_container\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr("list :move_target_container/Boris.txt")
      rsp.stderr.should eq("")
      rsp = cptr("list :move_source_container/Putin/Yeltsin/Boris.txt")
      rsp.stderr.should eq("Cannot find resource named ':move_source_container/Putin/Yeltsin/Boris.txt'.\n")
    end
  end

  context "when destination directory can't be written" do
    before(:all) do
      unwritable = 'spec/tmp/move/unwriteable/'
      FileUtils.mkdir_p(unwritable) unless File.exists?(unwritable)
      FileUtils.chmod(0000, unwritable)
    end
    
    it "should fail" do
      rsp = cptr("move :move_source_container/Putin/Medvedev.txt spec/tmp/move/unwriteable/")

      path = File.expand_path(File.dirname(__FILE__) + '/../../..')
      rsp.stderr.should eq("Permission denied - #{path}/spec/tmp/move/unwriteable/Medvedev.txt\n")
      rsp.stdout.should eq("")
    end
  end
  
  context "when target file can't be written" do
    before(:all) do
      unwritable = 'spec/tmp/move/target.txt'
      FileUtils.touch(unwritable) unless File.exists?(unwritable)
      FileUtils.chmod(0000, unwritable)
    end
    
    it "should fail" do
      rsp = cptr("move :move_source_container/Putin/Medvedev.txt spec/tmp/move/target.txt")

      path = File.expand_path(File.dirname(__FILE__) + '/../../..')
      rsp.stderr.should eq("Permission denied - #{path}/spec/tmp/move/target.txt\n")
      rsp.stdout.should eq("")
    end
  end
  
  context "successful container to directory" do
    it "should have created new object at destination etc" do
      rsp = cptr("move :move_source_container/Putin/Yeltsin/Gorbachev/Andropov.txt spec/tmp/move/")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Moved :move_source_container/Putin/Yeltsin/Gorbachev/Andropov.txt => spec/tmp/move/\n")
      rsp.exit_status.should be_exit(:success)
      File.exists?('spec/tmp/move/Andropov.txt').should be_true
      rsp = cptr("list :move_source_container/Putin/Gorbachev/Andropov.txt")
      rsp.stderr.should eq("Cannot find resource named ':move_source_container/Putin/Gorbachev/Andropov.txt'.\n")
    end

    after(:all) { File.unlink('spec/tmp/move/Andropov.txt') }
  end
  
  context "Trying to move a non-object resource" do
    it "should give error message" do
      rsp = cptr("move spec/fixtures/files/foo.txt :my_container")

      rsp.stderr.should eq("Move is limited to remote objects. Please use 'hpcloud copy' instead.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:incorrect_usage)
    end
  end
  
  context "with avl settings passed in" do
    it "should report success" do
      rsp = cptr("move :move_source_container/Putin/Yeltsin/Gorbachev/Chernenko.txt :move_target_container/new/foo.txt -z region-b.geo-1")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Moved :move_source_container/Putin/Yeltsin/Gorbachev/Chernenko.txt => :move_target_container/new/foo.txt\n")
      rsp.exit_status.should be_exit(:success)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "move with invalid avl" do
    it "should report error" do
      rsp = cptr("move :move_source_container/Putin/Vladimir.txt :move_target_container -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("move -a bogus :something/file.txt :somewhere")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end

  after(:all) do
    cptr("containers:remove -f :move_source_container :move_target_container")
    @localdir = 'spec/tmp/move/'
    FileUtils.rm_rf(@localdir) if File.exists?(@localdir)
  end
end

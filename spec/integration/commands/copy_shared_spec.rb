require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Copy shared resources" do
  before(:all) do
    rsp = cptr("remove -f :destainer")
    rsp = cptr("containers:add :destainer")
    rsp.stderr.should eq("")
    rsp = cptr("remove -f :copytainer")
    rsp = cptr("containers:add :copytainer")
    rsp.stderr.should eq("")
    username = AccountsHelper.get_username('secondary')
    rsp = cptr("acl:grant :copytainer rw #{username}")
    rsp.stderr.should eq("")
    rsp = cptr("location :copytainer")
    rsp.stderr.should eq("")
    @container = rsp.stdout.gsub("\n",'')
    @local = "spec/tmp/shared/"
    FileUtils.rm_rf(@local)
    FileUtils.mkdir_p(@local)

    #
    # Use this test to populate for the other tests
    #
    rsp = cptr("copy spec/fixtures/files/Matryoshka/Putin/Yeltsin/ #{@container}/ -a secondary")
    rsp.stderr.should eq("")
    rsp.stdout.should eq("Copied spec/fixtures/files/Matryoshka/Putin/Yeltsin/ => #{@container}/\n")
    rsp.exit_status.should be_exit(:success)
  end
  
  context "when container does not exist" do
    it "should exit with container not found" do
      missing = "#{@container}missing"
      rsp = cptr("copy #{missing} #{@local} -a secondary")

      rsp.stderr.should eq("Permission denied trying to access '#{missing}'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:permission_denied)
    end
  end

  context "when file and container exist" do
    it "should copy" do
      rsp = cptr("copy #{@container}/Yeltsin/Boris.txt #{@local} -a secondary")
puts "copy #{@container}/Yeltsin/Boris.txt #{@local} -a secondary"
puts rsp.stdout

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied #{@container}/Yeltsin/Boris.txt => #{@local}\n")
      rsp.exit_status.should be_exit(:success)
    end
  end
  
  context "when regex" do
    it "should copy" do
      rsp = cptr("copy #{@container}/Yeltsin/ #{@local} -a secondary")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied #{@container}/Yeltsin/ => #{@local}\n")
      rsp.exit_status.should be_exit(:success)
    end
  end
  
  context "when regex" do
    it "should copy" do
      rsp = cptr("copy #{@container}/Yeltsin/Gorbachev/.* #{@local} -a secondary")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied #{@container}/Yeltsin/Gorbachev/.* => #{@local}\n")
      rsp.exit_status.should be_exit(:success)
    end
  end
  
  context "when local file" do
    it "should copy" do
      rsp = cptr("copy spec/fixtures/files/Matryoshka/Putin/Yeltsin/Gorbachev/Andropov.txt #{@container}/ -a secondary")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied spec/fixtures/files/Matryoshka/Putin/Yeltsin/Gorbachev/Andropov.txt => #{@container}/\n")
      rsp.exit_status.should be_exit(:success)
    end
  end
  
  context "when container to container" do
    it "not allowed for now" do
      rsp = cptr("copy #{@container}/Yeltsin/Gorbachev/Andropov.txt #{@container}/spare/ -a secondary")

      rsp.stderr.should eq("403 Forbidden\n\nAccess was denied to this resource.\n\n   \n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
  end
  
  after(:all) do
    cptr("remove -f :copytainer")
  end
end

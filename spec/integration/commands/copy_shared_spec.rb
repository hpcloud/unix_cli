require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Copy shared resources" do
  before(:all) do
    rsp = cptr("remove -f :destainer")
    rsp = cptr("containers:add :destainer")
    rsp.stderr.should eq("")
    rsp = cptr("remove -f :copytainer")
    rsp = cptr("containers:add :copytainer")
    rsp.stderr.should eq("")
    rsp = cptr("copy spec/fixtures/files/Matryoshka/Putin/Yeltsin/ :copytainer")
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
  
  context "copy to shared" do
    it "should copy" do
      rsp = cptr("copy spec/fixtures/files/Matryoshka/Putin/Yeltsin #{@container} #{@local} -a secondary")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied spec/fixtures/files/Matryoshka/Putin/Yeltsin => #{@container}\n")
      rsp.exit_status.should be_exit(:success)
    end
  end
  
  after(:all) do
    #rsp = cptr("remove -f :copytainer")
    #rsp.stderr.should eq("")
  end
end

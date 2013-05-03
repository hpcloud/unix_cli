require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Copy across" do
  
  before(:all) do
    file_name='spec/fixtures/files/Matryoshka/Putin/Yeltsin/'
    rsp = cptr("containers:remove -f :duplicate")
    rsp = cptr("containers:add :duplicate")
    rsp = cptr("containers:remove -f :migrate")
    rsp = cptr("containers:add :migrate")
    rsp = cptr("containers:remove -f :aws")
    rsp = cptr("containers:add :aws")
    rsp.stderr.should eq("")
    rsp = cptr("containers:remove -f -a secondary :cross")
    rsp = cptr("containers:add -a secondary :cross")
    rsp.stderr.should eq("")
    rsp = cptr("copy -a secondary #{file_name} :cross")
    rsp.stderr.should eq("")
  end
    
  context "cross copy" do
    it "should copy files" do
      rsp = cptr('copy -s secondary :cross :duplicate')

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied :cross => :duplicate\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr('list :duplicate')
      rsp.stderr.should eq("")
      rsp.stdout.should eq("Yeltsin/Boris.txt\nYeltsin/Gorbachev/Andropov.txt\nYeltsin/Gorbachev/Chernenko.txt\nYeltsin/Gorbachev/Mikhail.txt\n")
    end
  end

  context "when migrate secondary" do
    it "should copy files" do
      rsp = cptr('migrate secondary :cross :migrate')

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Migrated :cross => :migrate\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr('list :migrate')
      rsp.stderr.should eq("")
      rsp.stdout.should eq("Yeltsin/Boris.txt\nYeltsin/Gorbachev/Andropov.txt\nYeltsin/Gorbachev/Chernenko.txt\nYeltsin/Gorbachev/Mikhail.txt\n")
    end
  end

  context "when migrate aws" do
    it "should copy files" do
      rsp = cptr('migrate aws :terryhowe.wordpress.com :aws')

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Migrated :terryhowe.wordpress.com => :aws\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr('list :aws')
      rsp.stderr.should eq("")
      rsp.stdout.should eq("WGI_0069.JPG\nfolder/WGI_0028.JPG\n")
    end
  end
end

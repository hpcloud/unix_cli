require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Copy across" do
  
  before(:all) do
    file_name='spec/fixtures/files/Matryoshka/Putin/Yeltsin/'
    rsp = cptr("containers:remove -f :duplicate")
    rsp = cptr("containers:add :duplicate")
    rsp.stderr.should eq("")
    rsp = cptr("containers:remove -f -a secondary :cross")
    rsp = cptr("containers:add -a secondary :cross")
    rsp.stderr.should eq("")
    rsp = cptr("copy -a secondary #{file_name} :cross")
    rsp.stderr.should eq("")
  end
    
  context "when local file does not exist" do
    it "should exit with file not found" do
      rsp = cptr('copy -s secondary :cross :duplicate')

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied :cross => :duplicate\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr('list :duplicate')
      rsp.stderr.should eq("")
      rsp.stdout.should eq("Yeltsin/Boris.txt\nYeltsin/Gorbachev/Andropov.txt\nYeltsin/Gorbachev/Chernenko.txt\nYeltsin/Gorbachev/Mikhail.txt\n")
    end
  end
end

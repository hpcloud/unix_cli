require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "lb:algorithms" do
  context "lb:algorithms" do
    it "should report success" do
      rsp = cptr("lb:algorithms -c name -d X")

      rsp.stderr.should eq("")
      rsp.stdout.should match("ROUND_ROBIN\nLEAST_CONNECTIONS\n")
      rsp.exit_status.should be_exit(:success)
    end
  end
end

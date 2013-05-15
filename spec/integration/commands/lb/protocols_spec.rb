require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "lb:protocols" do
  context "lb:protocols" do
    it "should report success" do
      rsp = cptr("lb:protocols -c name,port -d X")

      rsp.stderr.should eq("")
      rsp.stdout.should match("HTTPX80\nTCPX443\n")
      rsp.exit_status.should be_exit(:success)
    end
  end
end

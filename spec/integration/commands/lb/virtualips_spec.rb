require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "lb:virtualips" do
  context "lb:virtualips" do
    it "should report success" do
      cptr("lb:add cli_test_lb1 ROUND_ROBIN HTTP 80 -n 10.3.2.1:81")

      rsp = cptr("lb:virtualips -c ipVersion,type -d X cli_test_lb1")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("IPV4XPUBLIC\n")
      rsp.exit_status.should be_exit(:success)
    end
  end
end

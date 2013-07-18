require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "servers:limits" do
  context "servers:limits" do
    it "should report success" do
      rsp = cptr("servers:limits")

      rsp.stderr.should eq("")
      rsp.stdout.should include("maxTotalKeypairs:")
      rsp.stdout.should include("maxTotalFloatingIps:")
      rsp.stdout.should include("maxSecurityGroups:")
      rsp.stdout.should include("maxTotalInstances:")
      rsp.exit_status.should be_exit(:success)
    end
  end
end

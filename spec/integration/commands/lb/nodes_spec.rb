require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "lb:nodes" do
  before(:all) do
    cptr("lb:add cli_test_lb4 ROUND_ROBIN HTTP 80 -n 10.4.2.1,81;10.4.2.2,82")
  end

  context "lb:nodes" do
    it "should report success" do
      rsp = cptr("lb:nodes -c ip,port -d X cli_test_lb4")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("10.4.2.1X81\n10.4.2.2X82\n")
      rsp.exit_status.should be_exit(:success)
    end
  end
end

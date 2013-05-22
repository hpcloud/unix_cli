require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')

describe "lb:nodes:remove" do
  context "when creating" do
    it "should show success message" do
      @lb_name = "cli_test_lb3"
      rsp = cptr("lb:add #{@lb_name} ROUND_ROBIN HTTP 80 -n 10.29.2.2:80")
      rsp = cptr("lb:nodes:add #{@lb_name} 10.29.2.3 81")

      rsp = cptr("lb:nodes:remove #{@lb_name} 10.29.2.3:81")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed node '10.29.2.3:81' from load balancer '#{@lb_name}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "lb:update" do
  context "when creating" do
    it "should show success message" do
      @lb_name = "cliupdate1"
      cptr("lb:add #{@lb_name} LEAST_CONNECTIONS HTTP 80 -n 10.9.2.2:80")

      rsp = cptr("lb:update #{@lb_name} ROUND_ROBIN")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Updated load balancer '#{@lb_name}'.\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr("lb -c algorithm -d X #{@lb_name}")
      rsp.stdout.should eq("ROUND_ROBIN\n")

      rsp = cptr("lb:update #{@lb_name} LEAST_CONNECTIONS")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Updated load balancer '#{@lb_name}'.\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr("lb -c algorithm -d X #{@lb_name}")
      rsp.stdout.should eq("LEAST_CONNECTIONS\n")
    end
  end
end

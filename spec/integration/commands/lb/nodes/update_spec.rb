require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')

describe "lb:nodes:update" do
  context "when creating" do
    it "should show success message" do
      @lb_name = "cliupdate2"
      cptr("lb:add #{@lb_name} LEAST_CONNECTIONS HTTP 80 -n 10.9.2.2:80")

      rsp = cptr("lb:nodes:update #{@lb_name} 10.9.2.2:80 DISABLED")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Updated node '10.9.2.2:80' to 'DISABLED'.\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr("lb:nodes -c condition -d X #{@lb_name}")
      rsp.stdout.should eq("DISABLED\n")

      rsp = cptr("lb:nodes:update #{@lb_name} 10.9.2.2:80 ENABLED")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Updated node '10.9.2.2:80' to 'ENABLED'.\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr("lb:nodes -c condition -d X #{@lb_name}")
      rsp.stdout.should eq("ENABLED\n")
    end
  end
end

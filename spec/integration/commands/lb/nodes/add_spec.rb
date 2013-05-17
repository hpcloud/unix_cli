require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')

describe "lb:nodes:add" do
  context "when creating" do
    it "should show success message" do
      @lb_name = "cli_test_lb8"
      cptr("lb:add #{@lb_name} ROUND_ROBIN HTTP 80 -n 10.2.2.2,80")
      cptr("lb:nodes:remove 10.2.2.3 81")

      rsp = cptr("lb:nodes:add #{@lb_name} 10.2.2.3 81")

      rsp.stderr.should eq("")
      #@new_node_id = rsp.stdout.scan(/'([^']+)/)[2][0] #LBAAS-178
      @new_node_id = ''
      rsp.stdout.should eq("Created node '10.2.2.3:81' with id '#{@new_node_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr("lb:nodes #{@lb_name} -c address,port -d X")
      rsp.stdout.should include("10.2.2.2X80\n")
      rsp.stdout.should include("10.2.2.3X81\n")
    end

    after(:each) do
      cptr("lb:nodes:remove #{@lb_name} 10.2.2.3 81")
    end
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "lb:limits" do
  context "lb:limits" do
    it "should report success" do
      rsp = cptr("lb:limits -c max_load_balancer_name_length,max_load_balancers,max_nodes_per_load_balancer,max_vips_per_load_balancer -d X")

      rsp.stderr.should eq("")
      rsp.stdout.should match("128X80X50X1\n")
      rsp.exit_status.should be_exit(:success)
    end
  end
end

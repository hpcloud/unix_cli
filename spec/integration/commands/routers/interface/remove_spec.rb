require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')

describe "routers:interface:remove command" do
  before(:each) do
    @router_name = "routerone"
    @router = RouterTestHelper.create(@router_name)
    @port_name = "cli_test_port1"
    @port = PortTestHelper.create(@port_name)
  end

  context "when deleting router with name" do
    it "should succeed" do
      cptr("routers:interface:add #{@router_name} #{@port_name}")

      rsp = cptr("routers:interface:remove #{@router_name} #{@port_name}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed port interface '#{@port.id}' from '#{@router_name}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "routers:interface:remove with invalid avl" do
    it "should report error" do
      rsp = cptr("routers:interface:remove #{@router_name} #{@port_name} -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Network' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end

  context "routers:interface:remove with invalid router" do
    it "should report error" do
      rsp = cptr("routers:interface:remove bogus #{@port_name}")

      rsp.stderr.should eq("Cannot find a router matching 'bogus'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "routers:interface:remove with invalid port" do
    it "should report error" do
      rsp = cptr("routers:interface:remove #{@router_name} bogus")

      rsp.stderr.should eq("Cannot find a subnet or port matching 'bogus'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("routers:interface:remove bogus #{@port_name} -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end

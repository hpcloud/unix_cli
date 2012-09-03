require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "addresses:disassociate command" do
  before(:all) do
    @hp_svc = compute_connection
    @server_name = resource_name("ip")

    rsp = cptr('addresses:add')
    rsp.stderr.should eq("")
    @public_ip = rsp.stdout.scan(/'([^']+)/)[0][0]

    rsp = cptr('addresses:add')
    rsp.stderr.should eq("")
    @second_ip = rsp.stdout.scan(/'([^']+)/)[0][0]

    @server = @hp_svc.servers.create(:flavor_id => AccountsHelper.get_flavor_id(), :image_id => AccountsHelper.get_image_id(), :name => @server_name )
    @server.wait_for { ready? }
  end

  context "when specifying a bad IP address" do
    it "should show error message" do
      rsp = cptr('addresses:disassociate 111.111.111.111')

      rsp.stderr.should eq("You don't have an address with public IP '111.111.111.111', use `hpcloud addresses:add` to create one.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "when no server is associated" do
    it "should show success message" do
      rsp = cptr("addresses:disassociate #{@public_ip}")

      rsp.stderr.should eq("You don't have any server associated with address '#{@public_ip}'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "when specifying a good IP address" do
    it "should show success message" do
      # associate the address with the server
      address = get_address(@hp_svc, @public_ip)
      address.server = @server

      rsp = cptr("addresses:disassociate #{@public_ip}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Disassociated address '#{@public_ip}' from any server instance.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "disassociate ip with valid avl" do
    it "should report success" do
      # associate the address with the server
      address = get_address(@hp_svc, @second_ip)
      address.server = @server

      rsp = cptr("addresses:disassociate #{@second_ip} -z az-1.region-a.geo-1")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Disassociated address '#{@second_ip}' from any server instance.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "disassociate ip with invalid avl" do
    it "should report error" do
      rsp = cptr("addresses:disassociate #{@second_ip} -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("addresses:disassociate 127.0.0.1 -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end

  after(:all) do
    address = get_address(@hp_svc, @public_ip)
    address.server = nil if address and !address.instance_id.nil? # disassociate any server
    address.destroy if address # release the address
    address = get_address(@hp_svc, @second_ip)
    address.destroy if address

    @server.destroy if @server
  end
end

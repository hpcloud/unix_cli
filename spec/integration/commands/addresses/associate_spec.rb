require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "addresses:associate command" do
  before(:all) do
    @hp_svc = compute_connection
    @server_name = resource_name("ip")
    rsp = cptr('addresses:add')
    rsp.stderr.should eq("")
    @public_ip = rsp.stdout.scan(/'([^']+)/)[0][0]
    @server = @hp_svc.servers.create(:flavor_id => AccountsHelper.get_flavor_id(), :image_id => AccountsHelper.get_image_id(), :name => @server_name )
    @server.wait_for { ready? }
    rsp = cptr('addresses:add')
    rsp.stderr.should eq("")
    @second_ip = rsp.stdout.scan(/'([^']+)/)[0][0]
  end

  context "when specifying a bad IP address" do
    it "should show error message" do
      rsp = cptr('addresses:associate 111.111.111.111 myserver')

      rsp.stderr.should eq("You don't have an address with public IP '111.111.111.111', use `hpcloud addresses:add` to create one.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "when specifying a bad server name" do
    it "should show error message" do
      rsp = cptr("addresses:associate #{@public_ip} blah")

      rsp.stderr.should eql("You don't have a server 'blah'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "when specifying a good IP address and server id" do
    it "should show success message" do
      rsp = cptr("addresses:associate #{@public_ip} #{@server_name}")

      rsp.stderr.should eq("")
      rsp.stdout.should eql("Associated address '#{@public_ip}' to server '#{@server_name}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end


  context "associate ip with valid avl" do
    it "should report success" do
      rsp = cptr("addresses:associate #{@second_ip} #{@server_name} -z az-1.region-a.geo-1")

      rsp.stderr.should eq("")
      rsp.stdout.should eql("Associated address '#{@second_ip}' to server '#{@server_name}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "associate ip with invalid avl" do
    it "should report error" do
      rsp = cptr("addresses:associate #{@second_ip} #{@server_name} -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("addresses:associate 127.0.0.1 hal -a bogus")

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

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "servers:password command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = compute_connection
  end

  context "when changing password for server" do
    it "should show success message" do
      @server_name = resource_name("pwd1")
      @server = @hp_svc.servers.create(:flavor_id => AccountsHelper.get_flavor_id(), :image_id => AccountsHelper.get_image_id(), :name => @server_name )
      @server.wait_for { ready? }

      rsp = cptr("servers:password #{@server_name} Passw0rd1 ")

      rsp.stderr.should eq("")
      rsp.stdout.should eql("Password changed for server '#{@server_name}'.\n")
      rsp.exit_status.should be_exit(:success)
    end

    after(:all) do
      @server.destroy
    end
  end

  context "servers:password with valid avl" do
    it "should report success" do
      @server_name = resource_name("pwd2")
      @server = @hp_svc.servers.create(:flavor_id => AccountsHelper.get_flavor_id(), :image_id => AccountsHelper.get_image_id(), :name => @server_name )
      @server.wait_for { ready? }

      rsp = cptr("servers:password #{@server_name} Passw0rd1 -z az-1.region-a.geo-1")

      rsp.stdout.should eq("")
      rsp.stdout.should eq("Password changed for server '#{@server_name}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
    after(:all) do
      @server.destroy
    end
  end

  context "servers with invalid avl" do
    it "should report error" do
      rsp = cptr("servers:password server_name Passw0rd1 -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("servers:password server_name pass -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end

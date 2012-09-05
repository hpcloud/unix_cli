require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "servers:remove command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = compute_connection
  end

  context "when deleting server with name" do
    it "should show success message" do
      @server_name = resource_name("del1")
      server = @hp_svc.servers.create(:flavor_id => AccountsHelper.get_flavor_id(), :image_id => AccountsHelper.get_image_id(), :name => @server_name )
      server.wait_for { ready? }
      @server = @hp_svc.servers.get(server.id)

      rsp = cptr("servers:remove #{@server_name}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed server '#{@server_name}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "servers:remove with valid avl" do
    it "should report success" do
      @server_name = resource_name("del2")
      server = @hp_svc.servers.create(:flavor_id => AccountsHelper.get_flavor_id(), :image_id => AccountsHelper.get_image_id(), :name => @server_name )
      server.wait_for { ready? }
      @server = @hp_svc.servers.get(server.id)

      rsp = cptr("servers:remove #{@server_name} -z az-1.region-a.geo-1")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed server '#{@server_name}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "servers:remove with invalid avl" do
    it "should report error" do
      rsp = cptr("servers:remove server_name -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "servers:remove with invalid server" do
    it "should report error" do
      rsp = cptr("servers:remove bogus")

      rsp.stderr.should eq("Cannot find a server matching 'bogus'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("servers:remove something -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end

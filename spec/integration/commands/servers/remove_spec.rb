require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "servers:remove command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = compute_connection
  end

  context "when deleting server with name" do
    before(:all) do
      @server_name = resource_name("del1")
      server = @hp_svc.servers.create(:flavor_id => AccountsHelper.get_flavor_id(), :image_id => AccountsHelper.get_image_id(), :name => @server_name )
      server.wait_for { ready? }
      @server = @hp_svc.servers.get(server.id)

      @response, @exit = run_command("servers:remove #{@server_name}").stdout_and_exit_status
      sleep(15)
    end

    it "should show success message" do
      @response.should eql("Removed server '#{@server_name}'.\n")
    end

    ### server deletes take time to get it off the list
    pending "should not list in servers" do
      servers = @hp_svc.servers.map {|s| s.id}
      servers.should_not include(@server.id)
    end

    pending "should not exist" do
      server = @hp_svc.servers.get(@server.id)
      server.should be_nil
    end

  end

  describe "with avl settings passed in" do
    before(:all) do
      @server_name = resource_name("del2")
    end
    context "servers:remove with valid avl" do
      before(:all) do
        server = @hp_svc.servers.create(:flavor_id => AccountsHelper.get_flavor_id(), :image_id => AccountsHelper.get_image_id(), :name => @server_name )
        server.wait_for { ready? }
        @server = @hp_svc.servers.get(server.id)
      end
      it "should report success" do
        response, exit_status = run_command("servers:remove #{@server_name} -z az-1.region-a.geo-1").stdout_and_exit_status
        response.should eql("Removed server '#{@server_name}'.\n")
        exit_status.should be_exit(:success)
      end
    end
    context "servers:remove with invalid avl" do
      it "should report error" do
        response, exit_status = run_command("servers:remove #{@server_name} -z blah").stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
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

  end

end

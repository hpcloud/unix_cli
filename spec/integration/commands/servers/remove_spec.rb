require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "servers:remove command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = compute_connection
    @server_name = resource_name("del")
    server = @hp_svc.servers.create(:flavor_id => OS_COMPUTE_BASE_FLAVOR_ID, :image_id => OS_COMPUTE_BASE_IMAGE_ID, :name => @server_name )
    server.wait_for { ready? }
    @server = @hp_svc.servers.get(server.id)
  end

  context "when deleting server with name" do
    before(:all) do
      @response, @exit = run_command("servers:remove #{@server_name}").stdout_and_exit_status
      sleep(10)
    end

    it "should show success message" do
      @response.should eql("Removed server '#{@server_name}'.\n")
    end

    ### server deletes take time to get it off the list
    it "should not list in servers" do
      servers = @hp_svc.servers.map {|s| s.id}
      servers.should_not include(@server.id)
    end

    it "should not exist" do
      server = @hp_svc.servers.get(@server.id)
      server.should be_nil
    end

  end
end
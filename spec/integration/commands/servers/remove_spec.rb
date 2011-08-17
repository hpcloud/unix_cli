require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "servers:remove command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = compute_connection
  end

  context "when deleting server with id" do
    before(:all) do
      response = @hp_svc.run_instances('ami-00000005', 1, 1, {'InstanceType' => 'm1.small'})
      @new_server_id = response.body['instancesSet'][0]['instanceId']
      @server = get_server(@hp_svc, @new_server_id)
    end

    it "should show success message" do
      @response, @exit = run_command("servers:remove #{@new_server_id}").stdout_and_exit_status
      @response.should eql("Removed server '#{@new_server_id}'.\n")
      sleep(10)
    end

    ### server deletes take time to get it off the list
    pending "should not list in servers" do
      servers = @hp_svc.servers.map {|s| s.id}
      servers.should_not include(@new_server_id)
    end

    it "should not exist" do
      server = get_server(@hp_svc, @new_server_id)
      server.id.should_not eql(@new_server_id)
    end

  end
end
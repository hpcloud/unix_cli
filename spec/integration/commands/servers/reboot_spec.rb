require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "servers:reboot command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = compute_connection
  end

  ### Server creation returns status "failed to spawn", hence test fails
  pending "when rebooting server with id" do
    before(:all) do
      response = @hp_svc.run_instances('ami-00000007', 1, 1, {'InstanceType' => 'm1.small'})
      @new_server_id = response.body['instancesSet'][0]['instanceId']
      @server = get_server(@hp_svc, @new_server_id)
    end

    it "should show success message" do
      @response, @exit = run_command("servers:reboot #{@new_server_id}").stdout_and_exit_status
      @response.should eql("Rebooting server '#{@new_server_id}'.\n")
      sleep(10)
    end

    after(:all) do
      @server.destroy
    end

  end
end
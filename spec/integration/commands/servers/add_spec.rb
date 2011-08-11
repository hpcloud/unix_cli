require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "servers:add command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = compute_connection
  end

  ### Till we can get back the server id that is created, it cannot be deleted, hence marked pending
  pending "when creating server with name, image and defaults" do
    before(:all) do
      @response, @exit = run_command('servers:add fog-test-server ami-00000005').stdout_and_exit_status
      ### Need to somehow get back the server id after it is created
      #@new_server_id
    end

    pending "should show success message" do
      @response.should include("Created server 'fog-test-server'.\n")
    end
    its_exit_status_should_be(:success)

    pending "should list in servers" do
      servers = @hp_svc.servers.map {|s| s.id}
      servers.should include(@new_server_id)
    end

    after(:all) do
      server = get_server(@hp_svc, @new_server_id)
      server.destroy
    end
  end
end
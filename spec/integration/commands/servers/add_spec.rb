require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "servers:add command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = compute_connection
  end

  ### Till we can get back the server id that is created, it cannot be deleted, hence marked pending
  context "when creating server with name, image and defaults" do
    before(:all) do
      @response, @exit = run_command("servers:add fog-test-server #{OS_COMPUTE_BASE_IMAGE_ID}").stdout_and_exit_status
      @new_server_id = @response.scan(/'([^']+)/)[0][0]
    end

    it "should show success message" do
      @response.should include("Created server 'fog-test-server'")
    end
    its_exit_status_should_be(:success)

    it "should list id in servers" do
      servers = @hp_svc.servers.map {|s| s.id}
      servers.should include(@new_server_id.to_i)
    end
    it "should list name in servers" do
      servers = @hp_svc.servers.map {|s| s.name}
      servers.should include("fog-test-server")
    end

    after(:all) do
      server = get_server(@hp_svc, @new_server_id)
      server.destroy
    end
  end
end
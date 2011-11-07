require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "servers:reboot command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = compute_connection
  end

  ### Server creation returns status "failed to spawn", hence test fails
  context "when soft rebooting server" do
    before(:all) do
      server = @hp_svc.servers.create(:flavor_id => OS_COMPUTE_BASE_FLAVOR_ID, :image_id => OS_COMPUTE_BASE_IMAGE_ID, :name => "rebootserver" )
      @server = @hp_svc.servers.get(server.id)
    end

    it "should show success message" do
      @response, @exit = run_command("servers:reboot #{@server.name}").stdout_and_exit_status
      @response.should eql("Soft rebooting server '#{@server.name}'.\n")
      sleep(10)
    end

    after(:all) do
      @server.destroy
    end

  end
  context "when hard rebooting server" do
    before(:all) do
      server = @hp_svc.servers.create(:flavor_id => OS_COMPUTE_BASE_FLAVOR_ID, :image_id => OS_COMPUTE_BASE_IMAGE_ID, :name => "rebootserver" )
      @server = @hp_svc.servers.get(server.id)
    end

    it "should show success message" do
      @response, @exit = run_command("servers:reboot #{@server.name} -h").stdout_and_exit_status
      @response.should eql("Hard rebooting server '#{@server.name}'.\n")
      sleep(10)
    end

    after(:all) do
      @server.destroy
    end

  end
end
require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "servers:reboot command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = compute_connection
    @server_name = resource_name("reboot")
    server = @hp_svc.servers.create(:flavor_id => OS_COMPUTE_BASE_FLAVOR_ID, :image_id => OS_COMPUTE_BASE_IMAGE_ID, :name => @server_name )
    server.wait_for { ready? }
    @server = @hp_svc.servers.get(server.id)
  end

  ### Server creation returns status "failed to spawn", hence test fails
  pending "when soft rebooting server" do

    it "should show success message" do
      @response, @exit = run_command("servers:reboot #{@server_name}").stdout_and_exit_status
      @response.should eql("Soft rebooting server '#{@server_name}'.\n")
      sleep(10)
    end
  end

  pending "when hard rebooting server" do

    it "should show success message" do
      @response, @exit = run_command("servers:reboot #{@server_name} -h").stdout_and_exit_status
      @response.should eql("Hard rebooting server '#{@server_name}'.\n")
      sleep(10)
    end
  end

  pending "with avl settings passed in" do
    context "servers:reboot with valid avl" do
      it "should report success" do
        response, exit_status = run_command("servers:reboot #{@server_name} -z az-1.region-a.geo-1").stdout_and_exit_status
        response.should eql("Soft rebooting server '#{@server_name}'.\n")
        sleep(10)
        exit_status.should be_exit(:success)
      end
    end
    context "servers:reboot with invalid avl" do
      it "should report error" do
        response, exit_status = run_command("servers:reboot #{@server_name} -z blah").stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
    end
  end

  after(:all) do
    @server.destroy
  end

end
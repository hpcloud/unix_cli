require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "servers:password command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = compute_connection
  end

  context "when changing password for server" do
    before(:all) do
      @server_name = resource_name("pwd1")
      @server = @hp_svc.servers.create(:flavor_id => OS_COMPUTE_BASE_FLAVOR_ID, :image_id => OS_COMPUTE_BASE_IMAGE_ID, :name => @server_name )
      @server.wait_for { ready? }
    end

    it "should show success message" do
      @response, @exit = run_command("servers:password #{@server_name} Passw0rd1 ").stdout_and_exit_status
      @response.should eql("Password changed for server '#{@server_name}'.\n")
      sleep(10)
    end

    after(:all) do
      @server.destroy
    end
  end
  describe "with avl settings passed in" do
    before(:all) do
      @server_name = resource_name("pwd2")
    end
    context "servers:password with valid avl" do
      before(:all) do
        @server = @hp_svc.servers.create(:flavor_id => OS_COMPUTE_BASE_FLAVOR_ID, :image_id => OS_COMPUTE_BASE_IMAGE_ID, :name => @server_name )
        @server.wait_for { ready? }
      end
      it "should report success" do
        response, exit_status = run_command("servers:password #{@server_name} Passw0rd1 -z az-1.region-a.geo-1").stdout_and_exit_status
        response.should eql("Password changed for server '#{@server_name}'.\n")
        sleep(10)
        exit_status.should be_exit(:success)
      end
      after(:all) do
        @server.destroy
      end
    end
    context "servers with invalid avl" do
      it "should report error" do
        response, exit_status = run_command("servers:password #{@server_name} Passw0rd1 -z blah").stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
    end
  end

end
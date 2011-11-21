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
      server = @hp_svc.servers.create(:flavor_id => OS_COMPUTE_BASE_FLAVOR_ID, :image_id => OS_COMPUTE_BASE_IMAGE_ID, :name => "pwdserver" )
      server.wait_for { ready? }
    end

    it "should show success message" do
      @response, @exit = run_command("servers:password pwdserver Passw0rd1 ").stdout_and_exit_status
      @response.should eql("Password changed for server 'pwdserver'.\n")
    end

  end

end
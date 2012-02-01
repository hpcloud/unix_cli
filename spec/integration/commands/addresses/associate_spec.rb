require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "addresses:associate command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = compute_connection
    @server_name = resource_name("ip")
    response, exit = run_command('addresses:add').stdout_and_exit_status
    @public_ip = response.scan(/'([^']+)/)[0][0]
    @server = @hp_svc.servers.create(:flavor_id => OS_COMPUTE_BASE_FLAVOR_ID, :image_id => OS_COMPUTE_BASE_IMAGE_ID, :name => @server_name )
    @server.wait_for { ready? }
  end

  context "when specifying a bad IP address" do
    before(:all) do
      @response, @exit = run_command('addresses:associate 111.111.111.111 myserver').stderr_and_exit_status
    end

    it "should show error message" do
      @response.should eql("You don't have an address with public IP '111.111.111.111', use `hpcloud addresses:add` to create one.\n")
    end
    its_exit_status_should_be(:not_found)
  end
  context "when specifying a bad server name" do
    before(:all) do
      @response, @exit = run_command("addresses:associate #{@public_ip} blah").stderr_and_exit_status
    end

    it "should show error message" do
      @response.should eql("You don't have a server 'blah'.\n")
    end
    its_exit_status_should_be(:not_found)
  end
  context "when specifying a good IP address and server id" do
    before(:all) do
      @response, @exit = run_command("addresses:associate #{@public_ip} #{@server_name}").stdout_and_exit_status
    end

    it "should show success message" do
      @response.should eql("Associated address '#{@public_ip}' to server '#{@server_name}'.\n")
    end
    its_exit_status_should_be(:success)
  end

  after(:all) do
    address = get_address(@hp_svc, @public_ip)
    address.server = nil if address and !address.instance_id.nil? # disassociate any server
    address.destroy if address # release the address
    @server.destroy if @server
  end

end
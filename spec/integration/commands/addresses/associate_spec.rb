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
    @server = @hp_svc.servers.create(:flavor_id => AccountsHelper.get_flavor_id(), :image_id => AccountsHelper.get_image_id(), :name => @server_name )
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

  context "with avl settings passed in" do
    before(:all) do
      resp, exit = run_command('addresses:add').stdout_and_exit_status
      @second_ip = resp.scan(/'([^']+)/)[0][0]
    end

    context "associate ip with valid avl" do
      it "should report success" do
        response, exit_status = run_command("addresses:associate #{@second_ip} #{@server_name} -z az-1.region-a.geo-1").stdout_and_exit_status
        exit_status.should be_exit(:success)
      end
    end
    context "associate ip with invalid avl" do
      it "should report error" do
        response, exit_status = run_command("addresses:associate #{@second_ip} #{@server_name} -z blah").stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.set_options({}) }
    end
    after(:all) do
      address = get_address(@hp_svc, @second_ip)
      address.destroy if address
    end
  end

  after(:all) do
    address = get_address(@hp_svc, @public_ip)
    address.server = nil if address and !address.instance_id.nil? # disassociate any server
    address.destroy if address # release the address
    @server.destroy if @server
  end

end

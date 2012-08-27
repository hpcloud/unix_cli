require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "addresses:disassociate command" do
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
      @response, @exit = run_command('addresses:disassociate 111.111.111.111').stderr_and_exit_status
    end

    it "should show error message" do
      @response.should eql("You don't have an address with public IP '111.111.111.111', use `hpcloud addresses:add` to create one.\n")
    end
    its_exit_status_should_be(:not_found)
  end
  context "when no server is associated" do
    before(:all) do
      @response, @exit = run_command("addresses:disassociate #{@public_ip}").stdout_and_exit_status
    end

    it "should show success message" do
      @response.should eql("You don't have any server associated with address '#{@public_ip}'.\n")
    end
    its_exit_status_should_be(:success)
  end
  context "when specifying a good IP address" do
    before(:all) do
      # associate the address with the server
      address = get_address(@hp_svc, @public_ip)
      address.server = @server
      @response, @exit = run_command("addresses:disassociate #{@public_ip}").stdout_and_exit_status
    end

    it "should show success message" do
      @response.should eql("Disassociated address '#{@public_ip}' from any server instance.\n")
    end
    its_exit_status_should_be(:success)
  end

  context "with avl settings passed in" do
    before(:all) do
      resp, exit = run_command('addresses:add').stdout_and_exit_status
      @second_ip = resp.scan(/'([^']+)/)[0][0]
    end

    context "disassociate ip with valid avl" do
      it "should report success" do
        # associate the address with the server
        address = get_address(@hp_svc, @second_ip)
        address.server = @server
        response, exit_status = run_command("addresses:disassociate #{@second_ip} -z az-1.region-a.geo-1").stdout_and_exit_status
        exit_status.should be_exit(:success)
      end
    end
    context "disassociate ip with invalid avl" do
      it "should report error" do
        response, exit_status = run_command("addresses:disassociate #{@second_ip} -z blah").stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.clear_options() }
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

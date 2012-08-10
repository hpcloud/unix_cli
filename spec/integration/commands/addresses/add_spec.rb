require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "addresses:add command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = compute_connection
  end

  context "when creating address" do
    before(:all) do
      @response, @exit = run_command('addresses:add').stdout_and_exit_status
      @public_ip = @response.scan(/'([^']+)/)[0][0]
    end

    it "should show success message" do
      @response.should include("Created a public IP address")
    end
    its_exit_status_should_be(:success)

    it "should list in addresses" do
      addresses = @hp_svc.addresses.map {|a| a.ip}
      addresses.should include(@public_ip)
    end

    after(:all) do
      address = get_address(@hp_svc, @public_ip)
      address.destroy if address
    end
  end

  context "with avl settings passed in" do
    context "addresses:add with valid avl" do
      it "should report success" do
        response, exit_status = run_command('addresses:add -z az-1.region-a.geo-1').stdout_and_exit_status
        @public_ip = response.scan(/'([^']+)/)[0][0]
        exit_status.should be_exit(:success)
        address = get_address(@hp_svc, @public_ip)
        address.destroy if address
      end
    end
    context "addresses:add with invalid avl" do
      it "should report error" do
        response, exit_status = run_command('addresses:add -z blah').stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.set_options({}) }
    end

  end

end

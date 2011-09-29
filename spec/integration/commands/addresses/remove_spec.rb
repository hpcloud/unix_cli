require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "addresses:remove command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = compute_connection
  end

  context "when deleting an address" do
    before(:all) do
      @response, @exit = run_command('addresses:add').stdout_and_exit_status
      @public_ip = @response.scan(/'([^']+)/)[0][0]
    end

    it "should show success message" do
      response, @exit = run_command("addresses:remove #{@public_ip}").stdout_and_exit_status
      response.should eql("Removed address '#{@public_ip}'.\n")
    end

    it "should not list in addresses" do
      lambda {
        addresses = @hp_svc.addresses.map {|a| a.public_ip}
      }.should raise_error(Fog::AWS::Compute::Error)
    end

    it "should not exist" do
      lambda {
        address = get_address(@hp_svc, @public_ip)
      }.should raise_error(Fog::AWS::Compute::Error)
    end

  end
end
require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

#describe "addresses:add command" do
#  def cli
#    @cli ||= HP::Cloud::CLI.new
#  end
#
#  before(:all) do
#    @hp_svc = compute_connection
#  end
#
#  context "when creating address" do
#    before(:all) do
#      @response, @exit = run_command('addresses:add').stdout_and_exit_status
#      @public_ip = @response.scan(/'([^']+)/)[0][0]
#    end
#
#    it "should show success message" do
#      @response.should include("Created a public IP address")
#    end
#    its_exit_status_should_be(:success)
#
#    it "should list in addresses" do
#      addresses = @hp_svc.addresses.map {|a| a.public_ip}
#      addresses.should include(@public_ip)
#    end
#
#    after(:all) do
#      address = @hp_svc.addresses.select {|a| a.public_ip == @public_ip}.first
#      address.destroy if address
#    end
#  end
#end
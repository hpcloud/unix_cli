require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

#describe "addresses:assign command" do
#  def cli
#    @cli ||= HP::Cloud::CLI.new
#  end
#
#  before(:all) do
#    @hp_svc = compute_connection
#    response, exit = run_command('addresses:add').stdout_and_exit_status
#    @public_ip = response.scan(/'([^']+)/)[0][0]
#    response2 = @hp_svc.run_instances('ami-00000007', 1, 1, {'InstanceType' => 'm1.small'})
#    @new_server_id = response2.body['instancesSet'][0]['instanceId']
#  end
#
#  context "when specifying a bad IP address" do
#    before(:all) do
#      @response, @exit = run_command('addresses:assign 111.111.111.111 11111').stderr_and_exit_status
#    end
#
#    it "should show error message" do
#      @response.should eql("You don't have an address with public IP '111.111.111.111', use `hpcloud addresses:add` to create one.\n")
#    end
#    its_exit_status_should_be(:not_found)
#  end
#  context "when specifying a bad server id" do
#    before(:all) do
#      @response, @exit = run_command("addresses:assign #{@public_ip} 11111").stderr_and_exit_status
#    end
#
#    it "should show error message" do
#      @response.should eql("You don't have a server with id '11111'.\n")
#    end
#    its_exit_status_should_be(:not_found)
#  end
#  context "when specifying a good IP address and server id" do
#    before(:all) do
#      @response, @exit = run_command("addresses:assign #{@public_ip} #{@new_server_id}").stdout_and_exit_status
#    end
#
#    it "should show success message" do
#      @response.should eql("Assigned address '#{@public_ip}' to server with id '#{@new_server_id}'.\n")
#    end
#    its_exit_status_should_be(:success)
#  end
#
#  after(:all) do
#    address = get_address(@hp_svc, @public_ip)
#    address.server = nil if address # diassociate any server
#    address.destroy if address # release the address
#    server = get_server(@hp_svc, @new_server_id)
#    server.destroy if server
#  end
#
#end
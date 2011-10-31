require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

#describe "keypairs:remove command" do
#  def cli
#    @cli ||= HP::Cloud::CLI.new
#  end
#
#  before(:all) do
#    @hp_svc = compute_connection
#  end
#
#  context "when deleting keypair" do
#    before(:all) do
#      @keypair = @hp_svc.key_pairs.create(:name => 'mykey', :fingerprint => 'c1:db:b5:bc:8b:b9:0f:33:62:53:de:80:6e:ae:67:66', :private_key => nil)
#    end
#
#    it "should show success message" do
#      @response, @exit = run_command("keypairs:remove #{@keypair.name}").stdout_and_exit_status
#      @response.should eql("Removed key pair '#{@keypair.name}'.\n")
#    end
#
#    it "should not list in keypairs" do
#      keypairs = @hp_svc.key_pairs.map {|k| k.name}
#      keypairs.should_not include(@keypair.name)
#    end
#
#    it "should not exist" do
#      keypair = get_keypair(@hp_svc, @keypair.name)
#      keypair.should be_nil
#    end
#
#  end
#end
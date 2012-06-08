require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "keypairs:remove command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = compute_connection
  end

  context "when deleting a keypair" do
    before(:all) do
      @key_name = 'fog-del-200'
      @keypair = @hp_svc.key_pairs.create(:name => @key_name)
    end

    it "should show success message" do
      @response, @exit = run_command("keypairs:remove #{@key_name}").stdout_and_exit_status
      @response.should eql("Removed key pair '#{@key_name}'.\n")
    end

    it "should not list in keypairs" do
      keypairs = @hp_svc.key_pairs.map {|k| k.name}
      keypairs.should_not include(@key_name)
    end

    it "should not exist" do
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.should be_nil
    end
  end

  context "when deleting a keypair with avl settings passed in" do
    before(:all) do
      @key_name = 'fog-del-201'
    end
    context "keypairs:remove with valid avl" do
      it "should report success" do
        @keypair = @hp_svc.key_pairs.create(:name => @key_name)
        response, exit_status = run_command("keypairs:remove #{@key_name} -z az-1.region-a.geo-1").stdout_and_exit_status
        response.should eql("Removed key pair '#{@key_name}'.\n")
        exit_status.should be_exit(:success)
      end
    end
    context "keypairs:remove with invalid avl" do
      it "should report error" do
        response, exit_status = run_command("keypairs:remove #{@key_name} -z blah").stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
    end
  end

end
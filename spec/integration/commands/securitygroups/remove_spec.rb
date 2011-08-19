require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "securitygroups:remove command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = compute_connection
  end

  context "when deleting security group" do
    before(:all) do
      securitygroup = @hp_svc.security_groups.new(:name => 'mysggroup', :description => 'sec group desc')
      securitygroup.save
    end

    it "should show success message" do
      @response, @exit = run_command("securitygroups:remove mysggroup").stdout_and_exit_status
      @response.should eql("Removed security group 'mysggroup'.\n")
    end

    it "should not list in security groups" do
      securitygroups = @hp_svc.security_groups.map {|k| k.name}
      securitygroups.should_not include('mysggroup')
    end

    it "should not exist" do
      securitygroup = get_securitygroup(@hp_svc, 'mysggroup')
      securitygroup.should be_nil
    end

  end
end
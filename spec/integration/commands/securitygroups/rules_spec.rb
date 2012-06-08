require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "Security Groups Rules command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = compute_connection
    @security_group = @hp_svc.security_groups.create(:name => 'mysggroup', :description => 'sec group desc')
    response = @security_group.create_rule(-1..-1, "icmp")
    @rule_id = response.body["security_group_rule"]["id"]
  end

  context "securitygroups:rules" do
    before(:all) do
      @response, @exit = run_command('securitygroups:rules mysggroup').stdout_and_exit_status
    end
    its_exit_status_should_be(:success)
  end

  context "securitygroups:rules:list" do
    before(:all) do
      @response, @exit = run_command('securitygroups:rules:list mysggroup').stdout_and_exit_status
    end
    its_exit_status_should_be(:success)
  end

  describe "with avl settings passed in" do
    context "securitygroups:rules with valid avl" do
      it "should report success" do
        response, exit_status = run_command('securitygroups:rules mysggroup -z az-1.region-a.geo-1').stdout_and_exit_status
        exit_status.should be_exit(:success)
      end
    end
    context "securitygroups:rules with invalid avl" do
      it "should report error" do
        response, exit_status = run_command('securitygroups:rules mysggroup -z blah').stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
    end
  end

  after(:all) do
    @security_group.delete_rule(@rule_id)
    @security_group.destroy if @security_group
  end

end
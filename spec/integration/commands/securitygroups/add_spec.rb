require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "securitygroups:add command" do
  before(:all) do
    @hp_svc = compute_connection
  end

  context "when creating security groups" do
    before(:all) do
      @response, @exit = capture_with_status(:stdout){ HP::Cloud::CLI.start(['securitygroups:add', 'mysecgroup', 'sec group desc']) }
    end

    it "should show success message" do
      @response.should eql("Created security group 'mysecgroup'.\n")
    end
    its_exit_status_should_be(:success)

    it "should list in security groups" do
      security_groups = @hp_svc.security_groups.map {|sg| sg.name}
      security_groups.should include('mysecgroup')
    end

    it "should have a name" do
      security_group = get_securitygroup(@hp_svc, 'mysecgroup')
      security_group.name.should eql('mysecgroup')
    end

    it "should have a description" do
      security_group = get_securitygroup(@hp_svc, 'mysecgroup')
      security_group.description.should eql('sec group desc')
    end

    it "should report security group exists if created again" do
      @response, @exit = capture_with_status(:stdout){ HP::Cloud::CLI.start(['securitygroups:add', 'mysecgroup', 'sec group desc']) }
      @response.should eql("Security group 'mysecgroup' already exists.\n")
    end

    after(:all) do
      security_group = get_securitygroup(@hp_svc, 'mysecgroup')
      security_group.destroy if security_group
    end
  end
end
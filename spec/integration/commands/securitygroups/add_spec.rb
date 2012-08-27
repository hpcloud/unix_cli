require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "securitygroups:add command" do
  before(:all) do
    @hp_svc = compute_connection
    sgroup = get_securitygroup(@hp_svc, 'mysecgroup')
    sgroup.destroy if sgroup
    sgroup2 = get_securitygroup(@hp_svc, 'mysecgroup2')
    sgroup2.destroy if sgroup2
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

  describe "with avl settings passed in" do
    context "securitygroups:add with valid avl" do
      it "should report success" do
        response, exit_status = run_command('securitygroups:add mysecgroup2 secdesc -z az-1.region-a.geo-1').stdout_and_exit_status
        exit_status.should be_exit(:success)
      end
      after(:all) do
        security_group = get_securitygroup(@hp_svc, 'mysecgroup2')
        security_group.destroy if security_group
      end
    end
    context "securitygroups:add with invalid avl" do
      it "should report error" do
        response, exit_status = run_command('securitygroups:add mysecgroup2 secdesc -z blah').stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.clear_options() }
    end
  end

end

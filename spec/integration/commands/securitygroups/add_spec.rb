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
    it "should show success message" do
      rsp = cptr(["securitygroups:add","mysecgroup","sec group desc"])

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Created security group 'mysecgroup'.\n")
      rsp.exit_status.should be_exit(:success)
      security_groups = @hp_svc.security_groups.map {|sg| sg.name}
      security_groups.should include('mysecgroup')
      security_group = get_securitygroup(@hp_svc, 'mysecgroup')
      security_group.name.should eql('mysecgroup')
      security_group = get_securitygroup(@hp_svc, 'mysecgroup')
      security_group.description.should eql('sec group desc')
      rsp = cptr(["securitygroups:add","mysecgroup","sec group desc"])
      rsp.stdout.should eql("Security group 'mysecgroup' already exists.\n")
    end

    after(:all) do
      security_group = get_securitygroup(@hp_svc, 'mysecgroup')
      security_group.destroy if security_group
    end
  end

  context "securitygroups:add with valid avl" do
    it "should report success" do
      rsp = cptr('securitygroups:add mysecgroup2 secdesc -z az-1.region-a.geo-1')
      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
    after(:all) do
      security_group = get_securitygroup(@hp_svc, 'mysecgroup2')
      security_group.destroy if security_group
    end
  end

  context "securitygroups:add with invalid avl" do
    it "should report error" do
      rsp = cptr('securitygroups:add mysecgroup2 secdesc -z blah')

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("securitygroups:add mysecgroup2 secdesc -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "securitygroups:remove command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = compute_connection
    del_securitygroup(@hp_svc, 'mysggroup')
    del_securitygroup(@hp_svc, 'mysggroup2')
  end

  context "when deleting security group" do
    before(:all) do
      securitygroup = @hp_svc.security_groups.new(:name => 'mysggroup', :description => 'sec group desc')
      securitygroup.save
    end

    it "should show success message" do
      rsp = cptr("securitygroups:remove mysggroup")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed security group 'mysggroup'.\n")
      rsp.exit_status.should be_exit(:success)
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

  context "securitygroups:remove with valid avl" do
    it "should report success" do
      securitygroup = @hp_svc.security_groups.new(:name => 'mysggroup2', :description => 'sec group desc')
      securitygroup.save

      rsp = cptr('securitygroups:remove mysggroup2 -z az-1.region-a.geo-1')

      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "securitygroups:remove with invalid avl" do
    it "should report error" do
      rsp = cptr('securitygroups:remove mysggroup2 -z blah')

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("securitygroups:remove mysggroup2 -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end

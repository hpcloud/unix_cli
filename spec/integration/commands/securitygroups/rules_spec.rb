require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "Security Groups Rules command" do
  before(:all) do
    @hp_svc = compute_connection
    del_securitygroup(@hp_svc, 'mysggroup')

    @security_group = @hp_svc.security_groups.create(:name => 'mysggroup', :description => 'sec group desc')
    response = @security_group.create_rule(-1..-1, "icmp")
    @rule_id = response.body["security_group_rule"]["id"]
  end

  context "securitygroups:rules" do
    it "should succeed" do
      rsp = cptr('securitygroups:rules mysggroup')

      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "securitygroups:rules:list" do
    it "should succeed" do
      rsp = cptr('securitygroups:rules:list mysggroup')

      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "securitygroups:rules with valid avl" do
    it "should report success" do
      rsp = cptr('securitygroups:rules mysggroup -z az-1.region-a.geo-1')

      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "securitygroups:rules with invalid avl" do
    it "should report error" do
      rsp = cptr('securitygroups:rules mysggroup -z blah')

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("securitygroups:rules mysggroup -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end

  after(:all) do
    @security_group.delete_rule(@rule_id)
    @security_group.destroy if @security_group
  end

end

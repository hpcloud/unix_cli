require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')

describe "securitygroups:rules:remove command" do
  before(:all) do
    @hp_svc = compute_connection
  end
  context "when removing rules" do
    before(:all) do
      @security_group = @hp_svc.security_groups.create(:name => 'delsecgroup', :description => 'sec group desc')
    end

    context "tcp with port range" do
      before(:all) do
        @security_group.create_rule(8080..8080, "tcp", "111.111.111.111/1")
        sec_group_with_rules = get_securitygroup(@hp_svc, 'delsecgroup')
        @rule_id = sec_group_with_rules.rules[0]["id"]
      end
      it "should show success message" do
        rsp = cptr("securitygroups:rules:remove delsecgroup #{@rule_id}")

        rsp.stderr.should eq("")
        rsp.stdout.should eq("Removed rule '#{@rule_id}' for security group 'delsecgroup'.\n")
        rsp.exit_status.should be_exit(:success)
        @rules = get_securitygroup(@hp_svc, 'delsecgroup')
        @rules.should have(0).rules
        rsp = cptr("securitygroups:rules:remove delsecgroup #{@rule_id}")
        rsp.exit_status.should be_exit(:not_found)
      end
    end

    context "for invalid security group" do
      it "should show error message" do
        rsp = cptr("securitygroups:rules:remove blah 333")

        rsp.stderr.should eq("You don't have a security group 'blah'.\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:not_found)
      end
    end

    context "servers with valid avl" do
      before(:all) do
        @security_group.create_rule(8081..8081, "tcp", "111.111.111.111/1")
        sec_group_with_rules = get_securitygroup(@hp_svc, 'delsecgroup')
        @rule_id = sec_group_with_rules.rules[0]["id"]
      end

      it "should report success" do
        rsp = cptr("securitygroups:rules:remove delsecgroup #{@rule_id} -z region-b.geo-1")

        rsp.stderr.should eq("")
        rsp.stdout.should eq("Removed rule '#{@rule_id}' for security group 'delsecgroup'.\n")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "servers with invalid avl" do
      it "should report error" do
        rsp = cptr("securitygroups:rules:remove delsecgroup 111 -z blah")

        rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.clear_options() }
    end

    after(:all) do
      @security_group.destroy if @security_group
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("securitygroups:rules:remove delsecgroup 111 -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end

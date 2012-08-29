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

        @response, @exit = capture_with_status(:stdout){ HP::Cloud::CLI.start(['securitygroups:rules:remove', 'delsecgroup', @rule_id]) }
        @rules = get_securitygroup(@hp_svc, 'delsecgroup')
      end
      it "should show success message" do
        @response.should eql("Removed rule '#{@rule_id}' for security group 'delsecgroup'.\n")
      end
      its_exit_status_should_be(:success)

      it "should have not any rule set" do
        @rules.should have(0).rules
      end

      it "should raise exception if rule does not exist and if removed again" do
        lambda {
          @response, @exit = capture_with_status(:stderr){ HP::Cloud::CLI.start(['securitygroups:rules:remove', 'delsecgroup', @rule_id]) }
        }.should raise_error(Fog::Compute::HP::NotFound)
      end

    end
    context "for invalid security group" do
      before(:all) do
        @response, @exit = capture_with_status(:stderr){ HP::Cloud::CLI.start(['securitygroups:rules:remove', 'blah', @rule_id]) }
      end
      it "should show error message" do
        @response.should eql("You don't have a security group 'blah'.\n")
      end
      its_exit_status_should_be(:not_found)

    end

    context "with avl settings passed in" do
      context "servers with valid avl" do
        before(:all) do
          @security_group.create_rule(8081..8081, "tcp", "111.111.111.111/1")
          sec_group_with_rules = get_securitygroup(@hp_svc, 'delsecgroup')
          @rule_id = sec_group_with_rules.rules[0]["id"]
        end
        it "should report success" do
          response, exit_status = run_command("securitygroups:rules:remove delsecgroup #{@rule_id} -z az-1.region-a.geo-1").stdout_and_exit_status
          response.should eql("Removed rule '#{@rule_id}' for security group 'delsecgroup'.\n")
          exit_status.should be_exit(:success)
        end
      end
      context "servers with invalid avl" do
        it "should report error" do
          response, exit_status = run_command("securitygroups:rules:remove delsecgroup 111 -z blah").stderr_and_exit_status
          response.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
          exit_status.should be_exit(:general_error)
        end
        after(:all) { Connection.instance.clear_options() }
      end
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

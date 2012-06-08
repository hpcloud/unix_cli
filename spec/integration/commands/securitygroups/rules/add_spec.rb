require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')

describe "securitygroups:rules:add command" do
  before(:all) do
    @hp_svc = compute_connection
  end

  context "when creating rules" do
    before(:all) do
      @security_group = @hp_svc.security_groups.create(:name => 'mysecgroup', :description => 'sec group desc')
    end

    context "tcp with port range" do
      before(:all) do
        @response, @exit = capture_with_status(:stdout){ HP::Cloud::CLI.start(['securitygroups:rules:add', 'mysecgroup', 'tcp', '-p', '22..22']) }
        sec_group_with_rules = get_securitygroup(@hp_svc, 'mysecgroup')
        @rule_id = sec_group_with_rules.rules[0]["id"]
        @rules = sec_group_with_rules.rules
      end

      it "should show success message" do
        @response.should eql("Created rule '#{@rule_id}' for security group 'mysecgroup'.\n")
      end
      its_exit_status_should_be(:success)

      it "should have a rule set" do
        @rules.should have(1).rule
      end

      it "should have an ip protocol" do
        @rules[0]['ip_protocol'].should eql('tcp')
      end

      it "should have an ip range " do
        @rules[0]['ip_range'].should_not be_nil
      end

      it "should have an ip address " do
        @rules[0]['ip_range']['cidr'].should eql("0.0.0.0/0")
      end

      it "should have a from port" do
        @rules[0]['from_port'].should eql(22)
      end

      it "should have a to port" do
        @rules[0]['to_port'].should eql(22)
      end

      it "should report rule exists if created again" do
        @response, @exit = capture_with_status(:stderr){ HP::Cloud::CLI.start(['securitygroups:rules:add', 'mysecgroup', 'tcp', '-p', '22..22']) }
        @response.should eql("This rule already exists in group #{@security_group.id}\n")
      end

      after(:all) do
        @security_group.delete_rule(@rule_id)
      end

    end
    context "tcp with port range and ip address" do
      before(:all) do
        @response, @exit = capture_with_status(:stdout){ HP::Cloud::CLI.start(['securitygroups:rules:add', 'mysecgroup', 'tcp', '-p', '80..80', '-c', '111.111.111.111/1']) }
        sec_group_with_rules = get_securitygroup(@hp_svc, 'mysecgroup')
        @rule_id = sec_group_with_rules.rules[0]["id"]
        @rules = sec_group_with_rules.rules
      end
      it "should show success message" do
        @response.should eql("Created rule '#{@rule_id}' for security group 'mysecgroup'.\n")
      end
      its_exit_status_should_be(:success)

      it "should have a rule set" do
        @rules.should have(1).rule
      end

      it "should have an ip protocol" do
        @rules[0]['ip_protocol'].should eql('tcp')
      end

      it "should have an ip range " do
        @rules[0]['ip_range'].should_not be_nil
      end

      it "should have an ip address " do
        @rules[0]['ip_range']['cidr'].should eql("111.111.111.111/1")
      end

      it "should have a from port" do
        @rules[0]['from_port'].should eql(80)
      end

      it "should have a to port" do
        @rules[0]['to_port'].should eql(80)
      end

      after(:all) do
        @security_group.delete_rule(@rule_id)
      end

    end
    context "tcp without port range" do
      before(:all) do
        @response, @exit = capture_with_status(:stderr){ HP::Cloud::CLI.start(['securitygroups:rules:add', 'mysecgroup', 'tcp']) }
      end
      it "should show error message" do
        @response.should eql("You have to specify a port range for any ip protocol other than 'icmp'.\n")
      end
      its_exit_status_should_be(:incorrect_usage)

    end
    context "icmp without port range" do
      before(:all) do
        @response, @exit = capture_with_status(:stdout){ HP::Cloud::CLI.start(['securitygroups:rules:add', 'mysecgroup', 'icmp']) }
        sec_group_with_rules = get_securitygroup(@hp_svc, 'mysecgroup')
        @rule_id = sec_group_with_rules.rules[0]["id"]
        @rules = sec_group_with_rules.rules
      end
      it "should show success message" do
        @response.should eql("Created rule '#{@rule_id}' for security group 'mysecgroup'.\n")
      end
      its_exit_status_should_be(:success)

      it "should have a rule set" do
        @rules.should have(1).rule
      end

      it "should have an ip protocol" do
        @rules[0]['ip_protocol'].should eql('icmp')
      end

      it "should have an ip range " do
        @rules[0]['ip_range'].should_not be_nil
      end

      it "should have an ip address " do
        @rules[0]['ip_range']['cidr'].should eql("0.0.0.0/0")
      end

      it "should have a from port" do
        @rules[0]['from_port'].should eql(-1)
      end

      it "should have a to port" do
        @rules[0]['to_port'].should eql(-1)
      end

      after(:all) do
        @security_group.delete_rule(@rule_id)
      end
    end

    context "inherit rule with tcp and source group" do
      before(:all) do
        # assumption that default security group already exists
        @response, @exit = capture_with_status(:stdout){ HP::Cloud::CLI.start(['securitygroups:rules:add', 'mysecgroup', 'tcp', '-p', '22..22', '-g', 'default']) }
        sec_group_with_rules = get_securitygroup(@hp_svc, 'mysecgroup')
        @rule_id = sec_group_with_rules.rules[0]["id"]
        @rules = sec_group_with_rules.rules
      end

      it "should show success message" do
        @response.should eql("Created rule '#{@rule_id}' for security group 'mysecgroup'.\n")
      end
      its_exit_status_should_be(:success)

      it "should have a rule set" do
        @rules.should have(1).rule
      end

      it "should have an ip protocol" do
        @rules[0]['ip_protocol'].should eql('tcp')
      end

      it "should have a group" do
        @rules[0]['group']['name'].should eql("default")
      end

      it "should have a from port" do
        @rules[0]['from_port'].should eql(22)
      end

      it "should have a to port" do
        @rules[0]['to_port'].should eql(22)
      end

      after(:all) do
        @security_group.delete_rule(@rule_id)
      end

    end
    context "inherit rule with icmp and source group" do
      before(:all) do
        # assumption that default security group already exists
        @response, @exit = capture_with_status(:stdout){ HP::Cloud::CLI.start(['securitygroups:rules:add', 'mysecgroup', 'icmp', '-g', 'default']) }
        sec_group_with_rules = get_securitygroup(@hp_svc, 'mysecgroup')
        @rule_id = sec_group_with_rules.rules[0]["id"]
        @rules = sec_group_with_rules.rules
      end

      it "should show success message" do
        @response.should eql("Created rule '#{@rule_id}' for security group 'mysecgroup'.\n")
      end
      its_exit_status_should_be(:success)

      it "should have a rule set" do
        @rules.should have(1).rule
      end

      it "should have an ip protocol" do
        @rules[0]['ip_protocol'].should eql('icmp')
      end

      it "should have a group" do
        @rules[0]['group']['name'].should eql("default")
      end

      it "should have a from port" do
        @rules[0]['from_port'].should eql(-1)
      end

      it "should have a to port" do
        @rules[0]['to_port'].should eql(-1)
      end

      after(:all) do
        @security_group.delete_rule(@rule_id)
      end

    end

    context "with invalid protocol" do
      before(:all) do
        @response, @exit = capture_with_status(:stderr){ HP::Cloud::CLI.start(['securitygroups:rules:add', 'mysecgroup', 'blah', '-p', '22..22']) }
      end
      it "should show error message" do
        @response.should eql("Invalid IP protocol blah.\n")
      end
      its_exit_status_should_be(:general_error)

    end
    context "with invalid ip range" do
      before(:all) do
        @response, @exit = capture_with_status(:stderr){ HP::Cloud::CLI.start(['securitygroups:rules:add', 'mysecgroup', 'tcp', '-p', '999999..999999']) }
      end
      it "should show error message" do
        @response.should eql("Invalid port range 999999:999999. Valid TCP ports should be between 1-65535\n")
      end
      its_exit_status_should_be(:general_error)

    end
    context "with invalid cidr" do
      before(:all) do
        @response, @exit = capture_with_status(:stderr){ HP::Cloud::CLI.start(['securitygroups:rules:add', 'mysecgroup', 'tcp', '-p', '8080..8080', '-c', '999.999.999.999/999']) }
      end
      it "should show error message" do
        @response.should eql("Invalid cidr 999.999.999.999/999.\n")
      end
      its_exit_status_should_be(:general_error)

    end
    context "with invalid source group" do
      before(:all) do
        @response, @exit = capture_with_status(:stderr){ HP::Cloud::CLI.start(['securitygroups:rules:add', 'mysecgroup', 'icmp', '-g', 'blah']) }
      end
      it "should show error message" do
        @response.should eql("You don't have a source security group 'blah'.\n")
      end
      its_exit_status_should_be(:not_found)

    end
    context "with invalid params - source group and ip address" do
      before(:all) do
        @response, @exit = capture_with_status(:stderr){ HP::Cloud::CLI.start(['securitygroups:rules:add', 'mysecgroup', 'icmp', '-c', '0.0.0.0/0', '-g', 'blah']) }
      end
      it "should show error message" do
        @response.should eql("You can either specify a source group or an ip address, not both.\n")
      end
      its_exit_status_should_be(:incorrect_usage)
    end

    context "with avl settings passed in" do
      context "securitygroups:rules:add with valid avl" do
        it "should report success" do
          @response, @exit_status = run_command('securitygroups:rules:add mysecgroup icmp -z az-1.region-a.geo-1').stdout_and_exit_status
          sec_group_with_rules = get_securitygroup(@hp_svc, 'mysecgroup')
          @rule_id = sec_group_with_rules.rules[0]["id"]
          @response.should eql("Created rule '#{@rule_id}' for security group 'mysecgroup'.\n")
          @exit_status.should be_exit(:success)
          @security_group.delete_rule(@rule_id)
        end
      end
      context "securitygroups:rules:add with invalid avl" do
        it "should report error" do
          response, exit_status = run_command('securitygroups:rules:add mysecgroup icmp -z blah').stderr_and_exit_status
          response.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
          exit_status.should be_exit(:general_error)
        end
      end
    end

    after(:all) do
      @security_group.destroy if @security_group
    end

  end
  context "when creating rules with invalid security group" do
    before(:all) do
      @response, @exit = capture_with_status(:stderr){ HP::Cloud::CLI.start(['securitygroups:rules:add', 'mysecgroup', 'tcp', '-p', '22..22']) }
    end
    it "should show error message" do
      @response.should eql("You don't have a security group 'mysecgroup'.\n")
    end
    its_exit_status_should_be(:not_found)

  end

end
require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')

describe "securitygroups:rules:add command" do
  before(:all) do
    @hp_svc = compute_connection
  end

  before(:all) do
    @security_group = @hp_svc.security_groups.create(:name => 'mysecgroup', :description => 'sec group desc')
  end

  context "tcp with port range" do
    it "should show success message" do
      rsp = cptr("securitygroups:rules:add mysecgroup tcp -p 22..22")

      rsp.stderr.should eq("")
      @rule_id = rsp.stdout.scan(/Created rule '([^']+)' for security group 'mysecgroup'./)
      rsp.exit_status.should be_exit(:success)
      sec_group_with_rules = get_securitygroup(@hp_svc, 'mysecgroup')
      @rules = sec_group_with_rules.rules
      @rules.should have(1).rule
      @rules[0]['ip_protocol'].should eql('tcp')
      @rules[0]['ip_range'].should_not be_nil
      @rules[0]['ip_range']['cidr'].should eql("0.0.0.0/0")
      @rules[0]['from_port'].should eql(22)
      @rules[0]['to_port'].should eql(22)
      rsp = cptr("securitygroups:rules:add mysecgroup tcp -p 22..22")
      rsp.stderr.should eq("This rule already exists in group #{@security_group.id}\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:incorrect_usage)
    end
  end

  context "tcp with port range and ip address" do
    it "should show success message and create group" do
      rsp = cptr("securitygroups:rules:add mysecgroup tcp -p 80..80 -c 111.111.111.111/1")

      rsp.stderr.should eq("")
      @rule_id = rsp.stdout.scan(/Created rule '([^']+)' for security group 'mysecgroup'./)
      rsp.exit_status.should be_exit(:success)
      sec_group_with_rules = get_securitygroup(@hp_svc, 'mysecgroup')
      @rules = sec_group_with_rules.rules
      @rules.should have(1).rule
      @rules[0]['ip_protocol'].should eql('tcp')
      @rules[0]['ip_range'].should_not be_nil
      @rules[0]['ip_range']['cidr'].should eql("111.111.111.111/1")
      @rules[0]['from_port'].should eql(80)
      @rules[0]['to_port'].should eql(80)
    end
  end

  context "tcp without port range" do
    it "should show error message" do
      rsp = cptr("securitygroups:rules:add mysecgroup tcp")

      rsp.stderr.should eq("You have to specify a port range for any ip protocol other than 'icmp'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:incorrect_usage)
    end
  end

  context "icmp without port range" do
    it "should show success message" do
      rsp = cptr("securitygroups:rules:add mysecgroup icmp")

      rsp.stderr.should eq("")
      @rule_id = rsp.stdout.scan(/Created rule '([^']+)' for security group 'mysecgroup'./)
      rsp.exit_status.should be_exit(:success)
      sec_group_with_rules = get_securitygroup(@hp_svc, 'mysecgroup')
      @rules = sec_group_with_rules.rules
      @rules.should have(1).rule
      @rules[0]['ip_protocol'].should eql('icmp')
      @rules[0]['ip_range'].should_not be_nil
      @rules[0]['ip_range']['cidr'].should eql("0.0.0.0/0")
      @rules[0]['from_port'].should eql(-1)
      @rules[0]['to_port'].should eql(-1)
    end
  end

  context "inherit rule with tcp and source group" do
    it "should show success and have a rule set" do
      # assumption that default security group already exists
      rsp = cptr("securitygroups:rules:add mysecgroup tcp -p 22..22 -g default")

      rsp.stderr.should eq("")
      @rule_id = rsp.stdout.scan(/Created rule '([^']+)' for security group 'mysecgroup'./)
      rsp.exit_status.should be_exit(:success)
      sec_group_with_rules = get_securitygroup(@hp_svc, 'mysecgroup')
      @rules = sec_group_with_rules.rules
      @rules.should have(1).rule
      @rules[0]['ip_protocol'].should eql('tcp')
      @rules[0]['group']['name'].should eql("default")
      @rules[0]['from_port'].should eql(22)
      @rules[0]['to_port'].should eql(22)
    end
  end

  context "inherit rule with icmp and source group" do
    it "should show success message" do
      # assumption that default security group already exists
      rsp = cptr("securitygroups:rules:add mysecgroup icmp -g default")

      rsp.stderr.should eql("")
      @rule_id = rsp.stdout.scan(/Created rule '([^']+)' for security group 'mysecgroup'./)
      rsp.exit_status.should be_exit(:success)
      sec_group_with_rules = get_securitygroup(@hp_svc, 'mysecgroup')
      @rules = sec_group_with_rules.rules
      @rules.should have(1).rule
      @rules[0]['ip_protocol'].should eql('icmp')
      @rules[0]['group']['name'].should eql("default")
      @rules[0]['from_port'].should eql(-1)
      @rules[0]['to_port'].should eql(-1)
    end
  end

  context "with invalid protocol" do
    it "should show error message" do
      rsp = cptr("securitygroups:rules:add mysecgroup blah -p 22..22")

      rsp.stderr.should eq("Invalid IP protocol blah.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:incorrect_usage)
    end
  end

  context "with invalid ip range" do
    it "should show error message" do
      rsp = cptr("securitygroups:rules:add mysecgroup tcp -p 999999..999999")

      rsp.stderr.should eq("Invalid port range 999999:999999. Valid TCP ports should be between 1-65535\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:incorrect_usage)
    end
  end

  context "with invalid cidr" do
    it "should show error message" do
      rsp = cptr("securitygroups:rules:add mysecgroup tcp -p 8080..8080 -c 999.999.999.999/999")

      rsp.stderr.should eq("Invalid cidr 999.999.999.999/999.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:incorrect_usage)
    end
  end

  context "with invalid source group" do
    it "should show error message" do
      rsp = cptr("securitygroups:rules:add mysecgroup icmp -g blah")

      rsp.stderr.should eq("You don't have a source security group 'blah'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "with invalid params - source group and ip address" do
    it "should show error message" do
      rsp = cptr("securitygroups:rules:add mysecgroup icmp -c 0.0.0.0/0 -g blah")
      rsp.stderr.should eq("You can either specify a source group or an ip address, not both.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:incorrect_usage)
    end
  end

  context "securitygroups:rules:add with valid avl" do
    it "should report success" do
      rsp = cptr('securitygroups:rules:add mysecgroup icmp -z az-1.region-a.geo-1')

      rsp.stderr.should eq("")
      @rule_id = rsp.stdout.scan(/Created rule '([^']+)' for security group 'mysecgroup'./)
      rsp.stdout.should eq("Created rule '#{@rule_id}' for security group 'mysecgroup'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "securitygroups:rules:add with invalid avl" do
    it "should report error" do
      rsp = cptr('securitygroups:rules:add mysecgroup icmp -z blah')

      rsp.stdout.should eq("")
      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "when creating rules with invalid security group" do
    it "should show error message" do
      rsp = cptr("securitygroups:rules:add bogus tcp -p 22..22")

      rsp.stderr.should eq("You don't have a security group 'bogus'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("securitygroups:rules:add mysecgroup tcp -p 22..22 -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end

  after(:each) do
    @security_group.delete_rule(@rule_id) unless @rule_id.nil?
    @rule_id = nil
  end

  after(:all) do
    @security_group.destroy if @security_group
  end
end

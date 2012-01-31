require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')

#describe "securitygroups:ippermissions:add command" do
#  before(:all) do
#    @hp_svc = compute_connection
#  end
#
#  context "when creating IP permissions" do
#    context "tcp with port range" do
#      before(:all) do
#        @security_group = compute_connection.security_groups.new(:name => 'mysecgroup', :description => 'sec group desc')
#        @security_group.save
#        @response, @exit = capture_with_status(:stdout){ HP::Cloud::CLI.start(['securitygroups:ippermissions:add', 'mysecgroup', 'tcp', '22..22']) }
#        sec_group_with_ip_perms = get_securitygroup(@hp_svc, 'mysecgroup')
#        @ip_perms = sec_group_with_ip_perms.ip_permissions
#      end
#      it "should show success message" do
#        @response.should eql("Created IP permission for security group 'mysecgroup'.\n")
#      end
#      its_exit_status_should_be(:success)
#
#      it "should have an ip permissions set" do
#        @ip_perms.should have(1).permission
#      end
#
#      it "should have an ip protocol" do
#        @ip_perms[0]['ipProtocol'].should eql('tcp')
#      end
#
#      it "should have an ip range " do
#        @ip_perms[0]['ipRanges'].should_not be_nil
#      end
#
#      it "should have an ip address " do
#        @ip_perms[0]['ipRanges'][0]['cidrIp'].should eql("0.0.0.0/0")
#      end
#
#      it "should have a from port" do
#        @ip_perms[0]['fromPort'].should eql(22)
#      end
#
#      it "should have a to port" do
#        @ip_perms[0]['toPort'].should eql(22)
#      end
#
#      it "should report ip permission exists if created again" do
#        @response, @exit = capture_with_status(:stderr){ HP::Cloud::CLI.start(['securitygroups:ippermissions:add', 'mysecgroup', 'tcp', '22..22']) }
#        @response.should include("This rule already exists in group\n")
#      end
#
#      after(:all) do
#        @security_group.destroy if @security_group
#      end
#    end
#    context "tcp with port range and ip address" do
#      before(:all) do
#        @security_group = compute_connection.security_groups.new(:name => 'mysecgroup', :description => 'sec group desc')
#        @security_group.save
#        @response, @exit = capture_with_status(:stdout){ HP::Cloud::CLI.start(['securitygroups:ippermissions:add', 'mysecgroup', 'tcp', '80..80', '111.111.111.111/1']) }
#        sec_group_with_ip_perms = get_securitygroup(@hp_svc, 'mysecgroup')
#        @ip_perms = sec_group_with_ip_perms.ip_permissions
#      end
#      it "should show success message" do
#        @response.should eql("Created IP permission for security group 'mysecgroup'.\n")
#      end
#      its_exit_status_should_be(:success)
#
#      it "should have an ip permissions set" do
#        @ip_perms.should have(1).permission
#      end
#
#      it "should have an ip protocol" do
#        @ip_perms[0]['ipProtocol'].should eql('tcp')
#      end
#
#      it "should have an ip range " do
#        @ip_perms[0]['ipRanges'].should_not be_nil
#      end
#
#      it "should have an ip address " do
#        @ip_perms[0]['ipRanges'][0]['cidrIp'].should eql("111.111.111.111/1")
#      end
#
#      it "should have a from port" do
#        @ip_perms[0]['fromPort'].should eql(80)
#      end
#
#      it "should have a to port" do
#        @ip_perms[0]['toPort'].should eql(80)
#      end
#
#      after(:all) do
#        @security_group.destroy if @security_group
#      end
#    end
#    context "tcp without port range" do
#      before(:all) do
#        @security_group = compute_connection.security_groups.new(:name => 'mysecgroup', :description => 'sec group desc')
#        @security_group.save
#        @response, @exit = capture_with_status(:stderr){ HP::Cloud::CLI.start(['securitygroups:ippermissions:add', 'mysecgroup', 'tcp']) }
#        sec_group_with_ip_perms = get_securitygroup(@hp_svc, 'mysecgroup')
#        @ip_perms = sec_group_with_ip_perms.ip_permissions
#      end
#      it "should show error message" do
#        @response.should eql("You have to specify a port range for any ip protocol other than 'icmp'.\n")
#      end
#      its_exit_status_should_be(:general_error)
#
#      after(:all) do
#        @security_group.destroy if @security_group
#      end
#
#    end
#    context "icmp without port range" do
#      before(:all) do
#        @security_group = compute_connection.security_groups.new(:name => 'mysecgroup', :description => 'sec group desc')
#        @security_group.save
#        @response, @exit = capture_with_status(:stdout){ HP::Cloud::CLI.start(['securitygroups:ippermissions:add', 'mysecgroup', 'icmp']) }
#        sec_group_with_ip_perms = get_securitygroup(@hp_svc, 'mysecgroup')
#        @ip_perms = sec_group_with_ip_perms.ip_permissions
#      end
#      it "should show success message" do
#        @response.should eql("Created IP permission for security group 'mysecgroup'.\n")
#      end
#      its_exit_status_should_be(:success)
#
#      it "should have an ip permissions set" do
#        @ip_perms.should have(1).permission
#      end
#
#      it "should have an ip protocol" do
#        @ip_perms[0]['ipProtocol'].should eql('icmp')
#      end
#
#      it "should have an ip range " do
#        @ip_perms[0]['ipRanges'].should_not be_nil
#      end
#
#      it "should have an ip address " do
#        @ip_perms[0]['ipRanges'][0]['cidrIp'].should eql("0.0.0.0/0")
#      end
#
#      it "should have a from port" do
#        @ip_perms[0]['fromPort'].should eql(-1)
#      end
#
#      it "should have a to port" do
#        @ip_perms[0]['toPort'].should eql(-1)
#      end
#
#      after(:all) do
#        @security_group.destroy if @security_group
#      end
#    end
#    context "for invalid security group" do
#      before(:all) do
#        @response, @exit = capture_with_status(:stderr){ HP::Cloud::CLI.start(['securitygroups:ippermissions:add', 'mysecgroup', 'tcp', '22..22']) }
#      end
#      it "should show error message" do
#        @response.should eql("You don't have a security group 'mysecgroup'.\n")
#      end
#      its_exit_status_should_be(:not_found)
#
#    end
#  end
#
#end
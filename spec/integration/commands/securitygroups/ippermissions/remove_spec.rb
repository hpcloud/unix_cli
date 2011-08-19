require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')

describe "securitygroups:ippermissions:remove command" do
  before(:all) do
    @hp_svc = compute_connection
  end
  context "when removing IP permissions" do
    before(:all) do
      @security_group = compute_connection.security_groups.new(:name => 'delsecgroup', :description => 'sec group desc')
      @security_group.save
    end
    context "tcp with port range" do
      before(:all) do
        ### setup an ip permission
        @response, @exit = capture_with_status(:stdout){ HP::Cloud::CLI.start(['securitygroups:ippermissions:add', 'delsecgroup', 'tcp', '22..22']) }

        @response, @exit = capture_with_status(:stdout){ HP::Cloud::CLI.start(['securitygroups:ippermissions:remove', 'delsecgroup', 'tcp', '22..22']) }
        sec_group_with_ip_perms = get_securitygroup(@hp_svc, 'delsecgroup')
        @ip_perms = sec_group_with_ip_perms.ip_permissions
      end
      it "should show success message" do
        @response.should eql("Removed IP permission for security group 'delsecgroup'.\n")
      end
      its_exit_status_should_be(:success)

      it "should have not any ip permissions set" do
        @ip_perms.should have(0).permissions
      end

      it "should report ip permission does not exist if removed again" do
        @response, @exit = capture_with_status(:stderr){ HP::Cloud::CLI.start(['securitygroups:ippermissions:remove', 'delsecgroup', 'tcp', '22..22']) }
        @response.should eql("ApiError => No rule for the specified parameters.\n")
      end

    end
    context "tcp with port range and ip address" do
      before(:all) do
        ### setup an ip permission
        @response, @exit = capture_with_status(:stdout){ HP::Cloud::CLI.start(['securitygroups:ippermissions:add', 'delsecgroup', 'tcp', '80..80', '111.111.111.111/1']) }

        @response, @exit = capture_with_status(:stdout){ HP::Cloud::CLI.start(['securitygroups:ippermissions:remove', 'delsecgroup', 'tcp', '80..80', '111.111.111.111/1']) }
        sec_group_with_ip_perms = get_securitygroup(@hp_svc, 'delsecgroup')
        @ip_perms = sec_group_with_ip_perms.ip_permissions
      end
      it "should show success message" do
        @response.should eql("Removed IP permission for security group 'delsecgroup'.\n")
      end
      its_exit_status_should_be(:success)

      it "should have not any ip permissions set" do
        @ip_perms.should have(0).permissions
      end

      it "should report ip permission does not exist if removed again" do
        @response, @exit = capture_with_status(:stderr){ HP::Cloud::CLI.start(['securitygroups:ippermissions:remove', 'delsecgroup', 'tcp', '80..80', '111.111.111.111/1']) }
        @response.should eql("ApiError => No rule for the specified parameters.\n")
      end

    end
    context "tcp without port range" do
      before(:all) do
        ### setup an ip permission
        @response, @exit = capture_with_status(:stderr){ HP::Cloud::CLI.start(['securitygroups:ippermissions:add', 'delsecgroup', 'tcp']) }

        @response, @exit = capture_with_status(:stderr){ HP::Cloud::CLI.start(['securitygroups:ippermissions:remove', 'delsecgroup', 'tcp']) }
        sec_group_with_ip_perms = get_securitygroup(@hp_svc, 'delsecgroup')
        @ip_perms = sec_group_with_ip_perms.ip_permissions
      end
      it "should show error message" do
        @response.should eql("You have to specify a port range for any ip protocol other than 'icmp'.\n")
      end
      its_exit_status_should_be(:general_error)

    end
    context "icmp without port range" do
      before(:all) do
        ### setup an ip permission
        @response, @exit = capture_with_status(:stdout){ HP::Cloud::CLI.start(['securitygroups:ippermissions:add', 'delsecgroup', 'icmp']) }

        @response, @exit = capture_with_status(:stdout){ HP::Cloud::CLI.start(['securitygroups:ippermissions:remove', 'delsecgroup', 'icmp']) }
        sec_group_with_ip_perms = get_securitygroup(@hp_svc, 'delsecgroup')
        @ip_perms = sec_group_with_ip_perms.ip_permissions
      end
      it "should show success message" do
        @response.should eql("Removed IP permission for security group 'delsecgroup'.\n")
      end
      its_exit_status_should_be(:success)

      it "should have not any ip permissions set" do
        @ip_perms.should have(0).permissions
      end

      it "should report ip permission does not exist if removed again" do
        @response, @exit = capture_with_status(:stderr){ HP::Cloud::CLI.start(['securitygroups:ippermissions:remove', 'delsecgroup', 'icmp']) }
        @response.should eql("ApiError => No rule for the specified parameters.\n")
      end

    end
    context "for invalid security group" do
      before(:all) do
        @response, @exit = capture_with_status(:stderr){ HP::Cloud::CLI.start(['securitygroups:ippermissions:remove', 'mysecgroup', 'tcp', '22..22']) }
      end
      it "should show error message" do
        @response.should eql("You don't have a security group 'mysecgroup'.\n")
      end
      its_exit_status_should_be(:not_found)

    end

    after(:all) do
      @security_group.destroy if @security_group
    end

  end  
end
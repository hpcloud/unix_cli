require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')

describe "servers:securitygroups:add command" do
  context "when servers:securitygroups:add" do
    it "should show success message" do
      @sg_name = 'cli_test_sg9'
      SecurityGroupTestHelper.create(@sg_name)
      @server_name = "cli_test_srv1"
      server = ServerTestHelper.create(@server_name)

      rsp = cptr("servers:securitygroups:add #{@server_name} #{@sg_name}")

      rsp.stderr.should eql("")
      rsp.stdout.should eql("Added security group '#{@sg_name}' to server '#{@server_name}'.\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr("servers -d X -c name,security_groups #{@server_name}")
      rsp.stderr.should eql("")
      rsp.stdout.should eql("#{@server_name}Xdefault, #{@sg_name}\n")
       
      rsp = cptr("servers:securitygroups:remove #{@server_name} #{@sg_name}")

      rsp = cptr("servers -d X -c name,security_groups #{@server_name}")
      rsp.stderr.should eql("")
      rsp.stdout.should eql("#{@server_name}Xdefault\n")
    end
  end
end

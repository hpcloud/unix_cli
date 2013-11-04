# encoding: utf-8
#
# © Copyright 2013 Hewlett-Packard Development Company, L.P.
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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

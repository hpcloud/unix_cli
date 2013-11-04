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

describe "routers:interface:add" do
  before(:each) do
    username = AccountsHelper.get_username('primary')
    @routers_name = "#{username}-router"
    cptr("routers:add #{@routers_name}")
    @port_name = "cli_test_port1"
    @port = PortTestHelper.create(@port_name)
    rsp = cptr("addresses -c id -d X")
    addressid = rsp.stdout
  end

  context "when creating router" do
    it "should show success message" do
      cptr("hpcloud ports:update -d '' #{@port_name}")
      cptr("routers:interface:remove #{@routers_name} #{@port_name}")

      rsp = cptr("routers:interface:add #{@routers_name} #{@port_name}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Created router interface '#{@routers_name}' to '#{@port.id}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "routers:interface:add bogus" do
    it "should fail" do
      rsp = cptr("routers:interface:add #{@routers_name} bogus")

      rsp.stderr.should eq("Cannot find a subnet or port matching 'bogus'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "when creating routers with a name that already exists" do
    it "should fail" do
      cptr("routers:interface:add #{@routers_name} #{@port_name}")

      rsp = cptr("routers:interface:add #{@routers_name} #{@port_name}")

      rsp.stderr.should match("Unable to complete operation on port #{@port.id}")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:conflicted)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("routers:interface:add #{@routers_name} #{@port_name} -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end

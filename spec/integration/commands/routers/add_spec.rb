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

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "routers:add" do
  before(:each) do
    @network = NetworkTestHelper.create("Ext-Net")
    username = AccountsHelper.get_username('primary')
    @routers_name = "#{username}-router"
  end

  context "when creating router" do
    it "should show success message" do
      cptr("routers:remove #{@routers_name}")

      rsp = cptr("routers:add #{@routers_name}")

      rsp.stderr.should eq("")
      @new_routers_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created router '#{@routers_name}' with id '#{@new_routers_id}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "router:add with all the options" do
    it "should show success message" do
      cptr("routers:remove #{@routers_name}")

      rsp = cptr("routers:add #{@routers_name} -g #{@network.id} -u")

      rsp.stderr.should eq("")
      @new_routers_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created router '#{@routers_name}' with id '#{@new_routers_id}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "when creating routers with a name that already exists" do
    it "should fail" do
      cptr("routers:add #{@routers_name}")

      rsp = cptr("routers:add #{@routers_name} -g #{@network.name}")

      rsp.stderr.should eq("A router with the name '#{@routers_name}' already exists\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("routers:add #{@routers_name} -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end

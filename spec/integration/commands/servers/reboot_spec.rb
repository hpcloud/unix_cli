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

describe "servers:reboot command" do
  context "when soft rebooting server" do
    it "should show success message" do
      @server_name = "cli_test_srv4"
      server = ServerTestHelper.create(@server_name)

      rsp = cptr("servers:reboot #{@server_name}")

      rsp.stderr.should eql("")
      rsp.stdout.should eql("Soft rebooting server '#{@server_name}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "when hard rebooting server" do
    it "should show success message" do
      @server_name = "cli_test_srv5"
      server = ServerTestHelper.create(@server_name)

      rsp = cptr("servers:reboot #{@server_name} -h")

      rsp.stderr.should eql("")
      rsp.stdout.should eql("Hard rebooting server '#{@server_name}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "servers:reboot with valid avl" do
    it "should report success" do
      @server_name = "cli_test_srv6"
      server = ServerTestHelper.create(@server_name)

      rsp = cptr("servers:reboot #{@server_name} -z region-b.geo-1")

      rsp.stderr.should eql("")
      rsp.stdout.should eql("Soft rebooting server '#{@server_name}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "servers:reboot with invalid avl" do
    it "should report error" do
      rsp = cptr("servers:reboot server_name -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("servers:reboot server_name -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end

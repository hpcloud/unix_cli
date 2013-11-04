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

#require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')
#
#describe "servers:password command" do
#  def cli
#    @cli ||= HP::Cloud::CLI.new
#  end
#
#  before(:all) do
#    @hp_svc = compute_connection
#  end
#
#  context "when changing password for server" do
#    it "should show success message" do
#      ServerTestHelper.create("cli_test_srv1")
#
#      rsp = cptr("servers:password cli_test_srv1 Passw0rd1 ")
#
#      rsp.stderr.should eq("")
#      rsp.stdout.should eql("Password changed for server 'cli_test_srv1'.\n")
#      rsp.exit_status.should be_exit(:success)
#    end
#  end
#
#  context "servers:password with valid avl" do
#    it "should report success" do
#      ServerTestHelper.create("cli_test_srv1")
#
#      rsp = cptr("servers:password cli_test_srv1 Passw0rd2 -z region-b.geo-1")
#
#      rsp.stderr.should eq("")
#      rsp.stdout.should eq("Password changed for server 'cli_test_srv1'.\n")
#      rsp.exit_status.should be_exit(:success)
#    end
#  end
#
#  context "servers with invalid avl" do
#    it "should report error" do
#      rsp = cptr("servers:password cli_test_srv1 Passw0rd1 -z blah")
#
#      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
#      rsp.stdout.should eq("")
#      rsp.exit_status.should be_exit(:general_error)
#    end
#    after(:all) { Connection.instance.clear_options() }
#  end
#
#  context "verify the -a option is activated" do
#    it "should report error" do
#      AccountsHelper.use_tmp()
#
#      rsp = cptr("servers:password cli_test_srv1 pass -a bogus")
#
#      tmpdir = AccountsHelper.tmp_dir()
#      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
#      rsp.stdout.should eq("")
#      rsp.exit_status.should be_exit(:general_error)
#    end
#    after(:all) {reset_all()}
#  end
#end

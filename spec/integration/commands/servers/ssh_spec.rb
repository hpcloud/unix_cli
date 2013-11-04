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

describe "servers:ssh" do
  before(:all) do
    keypair = KeypairTestHelper.create("cli_test_key1")
    @server1 = ServerTestHelper.create("cli_test_srv1")
    keypair.private_read
    keypair.name = "#{@server1.id}"
    keypair.private_add
    @server2 = ServerTestHelper.create("cli_test_srv2")
  end

  context "when using no option and the server is known" do
    it "should show success message" do

      rsp = cptr("servers:ssh cli_test_srv1 -c echo")

      rsp.stderr.should eq("")
      rsp.stdout.should include("Connecting to 'cli_test_srv1'...\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "when using no option" do
    it "should fail" do
      FileUtils.rm_f(KeypairHelper.private_filename("#{@server2.id}"))

      rsp = cptr("servers:ssh cli_test_srv2 -c echo")

      expected_str = "There is no local configuration to determine what private key is associated with this server.  Use the keypairs:private:add command to add a key named #{@server2.id} for this server or use the -k or -p option.\n"
      rsp.stderr.should eq(expected_str)
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:incorrect_usage)
    end
  end

  context "when using the -k option" do
    it "should succeed" do
      rsp = cptr("servers:ssh cli_test_srv2 -k cli_test_key1 -c echo")

      rsp.stderr.should eq("")
      rsp.stdout.should include("Connecting to 'cli_test_srv2'...\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "when using the -p option" do
    it "should succeed" do
      filename = KeypairHelper.private_filename("cli_test_key1")
      rsp = cptr("servers:ssh cli_test_srv2 -p #{filename} -c echo")

      rsp.stderr.should eq("")
      rsp.stdout.should include("Connecting to 'cli_test_srv2'...\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "servers:ssh with valid avl" do
    it "should succeed" do
      rsp = cptr("servers:ssh cli_test_srv1 -z region-b.geo-1 -c echo")

      rsp.stderr.should eq("")
      rsp.stdout.should include("Connecting to 'cli_test_srv1'...\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "servers with invalid avl" do
    it "should report error" do
      rsp = cptr("servers:ssh cli_test_srv1 -z blah -c echo")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("servers:ssh cli_test_srv1 -a bogus -c echo")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end

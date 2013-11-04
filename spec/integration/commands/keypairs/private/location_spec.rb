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

describe "keypairs:private:location" do

  before(:all) do
    keypair = KeypairTestHelper.create("cli_test_key1")
    @server1 = ServerTestHelper.create("cli_test_srv1")
    @server2 = ServerTestHelper.create("cli_test_srv2")
    FileUtils.rm_f(KeypairHelper.private_filename("#{@server2.id}"))
    keypair.private_read
    keypair.name = "#{@server1.id}"
    keypair.private_add
  end

  context "location" do
    it "should show success message" do
      rsp = cptr("keypairs:private:location cli_test_srv1")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("#{ENV['HOME']}/.hpcloud/keypairs/#{@server1.id}.pem\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "location" do
    it "should show success message" do
      rsp = cptr("keypairs:private:location cli_test_srv2")

      rsp.stderr.should eq("Cannot find private key file for 'cli_test_srv2'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "location bogus" do
    it "should show failure message" do
      rsp = cptr("keypairs:private:location bogus_server")

      rsp.stderr.should eq("Cannot find a server matching 'bogus_server'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end
end

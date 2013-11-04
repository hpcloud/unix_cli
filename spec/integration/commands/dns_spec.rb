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

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Dnss command" do
  before(:all) do
    @dns1 = DnsTestHelper.create("clitest1.com.")
    cptr("dns:update clitest1.com. -e clitest@example.com -t 7200")
    @dns2= DnsTestHelper.create("clitest2.com.")
    cptr("dns:update clitest2.com. -e clitest@example.com -t 7200")
  end

  context "dns" do
    it "should report success" do
      rsp = cptr("dns -c name,ttl,email -d X #{@dns1.name} #{@dns2.name}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("clitest1.com.X7200Xclitest@example.com\nclitest2.com.X7200Xclitest@example.com\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "dns:list" do
    it "should report success" do
      rsp = cptr("dns:list -c name,ttl,email -d X #{@dns1.name} #{@dns2.name}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("clitest1.com.X7200Xclitest@example.com\nclitest2.com.X7200Xclitest@example.com\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "dns with valid avl" do
    it "should report success" do
      rsp = cptr("dns -c name,ttl,email -d X #{@dns1.name} #{@dns2.name} -z region-a.geo-1")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("clitest1.com.X7200Xclitest@example.com\nclitest2.com.X7200Xclitest@example.com\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "dns with invalid avl" do
    it "should report error" do
      rsp = cptr('dns -z blah')

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'DNS' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("dns -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end

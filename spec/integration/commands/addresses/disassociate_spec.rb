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

describe "addresses:disassociate command" do
  before(:all) do
    @port = PortTestHelper.create("cli_test_disasso")

    rsp = cptr('addresses:add')
    rsp.stderr.should eq("")
    @public_ip = rsp.stdout.scan(/'([^']+)/)[0][0]

    rsp = cptr('addresses:add')
    rsp.stderr.should eq("")
    @second_ip = rsp.stdout.scan(/'([^']+)/)[0][0]
  end

  context "when specifying a bad IP address" do
    it "should show error message" do
      rsp = cptr('addresses:disassociate 111.111.111.111')

      rsp.stderr.should eq("Cannot find an ip address matching '111.111.111.111'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "when no server is associated" do
    it "should show success message" do
      cptr("addresses:disassociate #{@public_ip}")

      rsp = cptr("addresses:disassociate #{@public_ip}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("You don't have any port associated with address '#{@public_ip}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "when specifying a good IP address" do
    it "should show success message" do
      rsp = cptr("addresses:associate #{@public_ip} #{@port.id}")
      rsp.stderr.should eq("")

      rsp = cptr("addresses:disassociate #{@public_ip}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Disassociated address '#{@public_ip}' from any server instance.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "disassociate ip with valid avl" do
    it "should report success" do
      puts("addresses:associate #{@public_ip} #{@port.id}")
      rsp = cptr("addresses:associate #{@public_ip} #{@port.id}")
      rsp.stderr.should eq("")

      rsp = cptr("addresses:disassociate #{@second_ip} -z region-b.geo-1")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Disassociated address '#{@second_ip}' from any server instance.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "disassociate ip with invalid avl" do
    it "should report error" do
      rsp = cptr("addresses:disassociate #{@second_ip} -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Network' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("addresses:disassociate 127.0.0.1 -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end

  after(:all) do
    rsp = cptr("addresses:remove #{@public_ip}")
    rsp = cptr("addresses:remove #{@second_ip}")
  end
end

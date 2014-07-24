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

describe "addresses:remove command" do
  before(:all) do
    @hp_svc = compute_connection

    rsp = cptr('addresses:add')
    rsp.stderr.should eq("")
    @public_ip = rsp.stdout.scan(/'([^']+)/)[0][0]

    rsp = cptr('addresses:add')
    rsp.stderr.should eq("")
    @second_ip = rsp.stdout.scan(/'([^']+)/)[0][0]
  end

  context "when deleting an address" do
    it "should show success message" do
      rsp = cptr("addresses:remove #{@public_ip}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed address '#{@public_ip}'.\n")
      rsp.exit_status.should be_exit(:success)
      addresses = @hp_svc.addresses.map {|a| a.ip}
      addresses.should_not include(@public_ip)
      address = get_address(@hp_svc, @public_ip)
      address.should be_nil
    end
  end

  context "remove ip with valid avl" do
    it "should report success" do
      rsp = cptr("addresses:remove #{@second_ip} -z #{REGION}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed address '#{@second_ip}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "remove two invalid ips" do
    it "should report success" do
      rsp = cptr("addresses:remove 127.0.0.1 127.0.0.2")

      rsp.stderr.should eq("Cannot find an ip address matching '127.0.0.1'.\nCannot find an ip address matching '127.0.0.2'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "remove ip with invalid avl" do
    it "should report error" do
      rsp = cptr("addresses:remove #{@second_ip} -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Network' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("addresses:remove 127.0.0.1 -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end

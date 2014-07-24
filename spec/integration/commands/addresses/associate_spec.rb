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

describe "addresses:associate command" do
  before(:all) do
    @hp_svc = compute_connection
    @port1 = PortTestHelper.create('cli_test_port1')
    @port2 = PortTestHelper.create('cli_test_port2')
    rsp = cptr('addresses:add')
    rsp.stderr.should eq("")
    @first_ip = rsp.stdout.scan(/'([^']+)/)[0][0]
    rsp = cptr('addresses:add')
    rsp.stderr.should eq("")
    @second_ip = rsp.stdout.scan(/'([^']+)/)[0][0]
  end

  context "when specifying a bad IP address" do
    it "should show error message" do
      rsp = cptr("addresses:associate 111.111.111.111 #{@port1.name}")

      rsp.stderr.should eq("Cannot find an ip address matching '111.111.111.111'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "when specifying a bad server name" do
    it "should show error message" do
      rsp = cptr("addresses:associate #{@first_ip} blah")

      rsp.stderr.should eql("Cannot find a port matching 'blah'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "when specifying a good IP address and server id" do
    it "should show success message" do
      rsp = cptr("addresses:associate #{@first_ip} #{@port1.name}")

      rsp.stderr.should eq("")
      rsp.stdout.should eql("Associated address '#{@first_ip}' to server '#{@port1.name}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "when IP address is already used" do
    it "should show failure message" do
      rsp = cptr("addresses:associate #{@first_ip} #{@port1.name}")
      rsp.stderr.should eq("")

      rsp = cptr("addresses:associate #{@first_ip} #{@port2.name}")
      rsp.stderr.should eql("The IP address '#{@first_ip}' is in use by another server '#{@port1.id}'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:conflicted)
    end
  end

  context "when IP address is already associated" do
    it "should show success message" do
      rsp = cptr("addresses:associate #{@first_ip} #{@port1.name}")
      rsp.stderr.should eq("")

      rsp = cptr("addresses:associate #{@first_ip} #{@port1.name}")
      rsp.stderr.should eq("")
      rsp.stdout.should eql("The IP address '#{@first_ip}' is already associated with '#{@port1.name}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "associate ip with valid avl" do
    it "should report success" do
      rsp = cptr("addresses:associate #{@second_ip} #{@port1.name} -z #{REGION}")

      rsp.stderr.should eq("")
      rsp.stdout.should eql("Associated address '#{@second_ip}' to server '#{@port1.name}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "associate ip with invalid avl" do
    it "should report error" do
      rsp = cptr("addresses:associate #{@second_ip} #{@port1.name} -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Network' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("addresses:associate 127.0.0.1 hal -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end

  after(:all) do
    rsp = cptr("addresses:remove #{@first_ip}")
    rsp = cptr("addresses:remove #{@second_ip}")
  end
end

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

describe "subnets:add" do
  before(:each) do
    @network1 = NetworkTestHelper.create("cli_test_network1", true)
    @network1.subnets_array.each {|x|
      cptr("subnets:remove #{x}")
    }
  end

  context "when creating subnet" do
    it "should show success message" do
      @subnets_name = resource_name("add1")

      rsp = cptr("subnets:add #{@subnets_name} #{@network1.name} 127.0.1.0/32 -n 15.185.9.24")

      rsp.stderr.should eq("")
      @new_subnets_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created subnet '#{@subnets_name}' with id '#{@new_subnets_id}'.\n")
      rsp.exit_status.should be_exit(:success)
    end

    after(:each) do
      rsp = cptr("subnets:remove #{@subnets_name}")
      rsp.stderr.should eq("")
    end
  end

  context "subnet:add with all the options" do
    it "should show success message" do
      @subnets_name = resource_name("add2")

      rsp = cptr("subnets:add #{@subnets_name} #{@network1.name} 127.0.1.0/32 -i 4 -n 15.185.9.24 -d -h 127.0.1.0/32,10.2.2.2")

      rsp.stderr.should eq("")
      @new_subnets_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created subnet '#{@subnets_name}' with id '#{@new_subnets_id}'.\n")
      rsp.exit_status.should be_exit(:success)
    end

    after(:each) do
      rsp = cptr("subnets:remove #{@subnets_name}")
      rsp.stderr.should eq("")
    end
  end

  context "when creating subnets with a name that already exists" do
    it "should fail" do
      @sn1 = SubnetTestHelper.create("127.0.0.1")

      rsp = cptr("subnets:add #{@sn1.name} #{@network1.name} 127.0.0.1/32")

      rsp.stderr.should eq("Subnet with the name '#{@sn1.name}' already exists\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("subnets:add snler #{@network1.name} 127.0.0.1/32 -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end

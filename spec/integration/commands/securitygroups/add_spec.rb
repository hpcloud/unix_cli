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

describe "securitygroups:add command" do
  before(:all) do
    @hp_svc = compute_connection
    cptr('securitygroups:remove mysecgroup2 mysecgroup')
  end

  context "when creating security groups" do
    it "should show success message" do
      rsp = cptr(["securitygroups:add","mysecgroup","sec group desc"])

      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
      security_groups = @hp_svc.security_groups.map {|sg| sg.name}
      security_groups.should include('mysecgroup')
      security_group = get_securitygroup(@hp_svc, 'mysecgroup')
      security_group.name.should eql('mysecgroup')
      security_group = get_securitygroup(@hp_svc, 'mysecgroup')
      security_group.description.should eql('sec group desc')
      rsp.stdout.should eq("Created security group 'mysecgroup' with id '#{security_group.id}'.\n")
      rsp = cptr(["securitygroups:add","mysecgroup","sec group desc"])
      rsp.stderr.should eq("Security group 'mysecgroup' already exists.\n")
    end

    after(:all) do
      security_group = get_securitygroup(@hp_svc, 'mysecgroup')
      security_group.destroy if security_group
    end
  end

  context "securitygroups:add with valid avl" do
    it "should report success" do
      rsp = cptr('securitygroups:add mysecgroup2 secdesc -z region-b.geo-1')
      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
    after(:all) do
      security_group = get_securitygroup(@hp_svc, 'mysecgroup2')
      security_group.destroy if security_group
    end
  end

  context "securitygroups:add with invalid avl" do
    it "should report error" do
      rsp = cptr('securitygroups:add mysecgroup2 secdesc -z blah')

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("securitygroups:add mysecgroup2 secdesc -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end

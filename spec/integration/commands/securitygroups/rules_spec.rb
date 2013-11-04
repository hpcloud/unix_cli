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

describe "Security Groups Rules command" do
  before(:all) do
    @hp_svc = compute_connection
    cptr('securitygroups:remove mysggroup emptysg')

    @hp_svc.security_groups.create(:name => 'emptysg', :description => 'empty sg')
    @security_group = @hp_svc.security_groups.create(:name => 'mysggroup', :description => 'sec group desc')
    response = @security_group.create_rule(-1..-1, "icmp")
    @rule_id = response.body["security_group_rule"]["id"]
  end

  context "securitygroups:rules" do
    it "should succeed" do
      rsp = cptr('securitygroups:rules mysggroup')

      rsp.stdout.should match("source    | protocol | from | to |")
      rsp.stdout.should match("0.0.0.0/0 | icmp     | -1   | -1 |")
      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "securitygroups:rules empty" do
    it "should succeed with message" do
      rsp = cptr('securitygroups:rules emptysg')

      rsp.stdout.should eq("You currently have no rules for the security group 'emptysg'.\n")
      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "securitygroups:rules:list" do
    it "should succeed" do
      rsp = cptr('securitygroups:rules:list mysggroup')

      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "securitygroups:rules with valid avl" do
    it "should report success" do
      rsp = cptr('securitygroups:rules mysggroup -z region-b.geo-1')

      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "securitygroups:rules with invalid avl" do
    it "should report error" do
      rsp = cptr('securitygroups:rules mysggroup -z blah')

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("securitygroups:rules mysggroup -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end

  after(:all) do
    @security_group.delete_rule(@rule_id)
    @security_group.destroy if @security_group
  end

end

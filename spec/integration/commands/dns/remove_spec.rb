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

describe "dns:remove command" do
  def wait_for_gone(id)
      gone = false
      (0..15).each do |i|
        if HP::Cloud::Dnss.new.get(id.to_s).is_valid? == false
          gone = true
          break
        end
        sleep(1)
      end
      gone.should be_true
  end

  context "when deleting dns with name" do
    it "should succeed" do
      @dns = DnsTestHelper.create("everett1.com.")

      rsp = cptr("dns:remove #{@dns.name}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed dns '#{@dns.name}'.\n")
      rsp.exit_status.should be_exit(:success)
      wait_for_gone(@dns.id)
    end
  end

  context "dns:remove with valid avl" do
    it "should be successful" do
      @dns = DnsTestHelper.create("everett2.com.")

      rsp = cptr("dns:remove #{@dns.name} -z #{REGION}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed dns '#{@dns.name}'.\n")
      rsp.exit_status.should be_exit(:success)
      wait_for_gone(@dns.id)
    end
  end

  context "dns:remove with invalid avl" do
    it "should report error" do
      rsp = cptr("dns:remove dns_name -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'DNS' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end

    after(:all) do
      HP::Cloud::Connection.instance.clear_options()
    end
  end

  context "dns:remove with invalid dns" do
    it "should report error" do
      rsp = cptr("dns:remove bogus")

      rsp.stderr.should eq("Cannot find a dns matching 'bogus'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("dns:remove bogus -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end

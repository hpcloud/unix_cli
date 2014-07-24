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

describe "routers:remove command" do
  before(:each) do
    username = AccountsHelper.get_username('primary')
    @routers_name = "#{username}-router"
  end

  def wait_for_gone(name)
      gone = false
      (0..15).each do |i|
        begin
          HP::Cloud::Routers.new.get(name.to_s)
        rescue HP::Cloud::Exceptions::NotFound => e
          gone = true
          break
        end
        sleep(1)
      end
      gone.should be_true
  end

  context "when deleting router with name" do
    it "should succeed" do
      cptr("routers:add #{@router_name}")

      rsp = cptr("routers:remove #{@router_name}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed router '#{@router_name}'.\n")
      rsp.exit_status.should be_exit(:success)
      wait_for_gone(@router_name)
    end
  end

  context "routers:remove with valid avl" do
    it "should be successful" do
      cptr("routers:add #{@router_name} -z #{REGION}")

      rsp = cptr("routers:remove #{@router_name} -z #{REGION}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed router '#{@router_name}'.\n")
      rsp.exit_status.should be_exit(:success)
      wait_for_gone(@router_name)
    end
  end

  context "routers:remove with invalid avl" do
    it "should report error" do
      rsp = cptr("routers:remove #{@router_name} -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Network' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "routers:remove with invalid router" do
    it "should report error" do
      rsp = cptr("routers:remove bogus")

      rsp.stderr.should eq("Error removing router: Cannot find a router matching 'bogus'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("routers:remove bogus -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end

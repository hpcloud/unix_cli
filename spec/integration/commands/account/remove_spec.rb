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

describe "Account remove" do
  before(:all) do
    ConfigHelper.use_tmp()
    AccountsHelper.use_tmp()
    rsp = cptr("account:add mike auth_uri=one")
    rsp.stderr.should eq("")
    rsp = cptr("account:add lanegan account_id=one auth_uri=two")
    rsp.stderr.should eq("")
  end

  context "account:remove bogus" do
    it "should report success" do
      rsp = cptr("account:remove bogus notthere")

      rsp.stderr.should eq("Error removing account file: #{AccountsHelper.tmp_dir()}/.hpcloud/accounts/bogus\nError removing account file: #{AccountsHelper.tmp_dir()}/.hpcloud/accounts/notthere\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "account:remove" do
    it "should report success" do
      rsp = cptr("account:remove mike")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed account 'mike'\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr("account:list")
      rsp.stdout.should eq("lanegan\n")
    end
  end
  after(:all) {reset_all()}
end

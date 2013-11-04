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

describe "Account use" do
  before(:all) do
    ConfigHelper.use_tmp()
    AccountsHelper.use_tmp()
    rsp = cptr("account:add foo auth_uri=two block_availability_zone=3 read_timeout=4")
    rsp.stderr.should eq("")
  end

  before(:all) do
    rsp = cptr("config:set default_account=default")
    rsp.stderr.should eq("")
    rsp = cptr("account:add default auth_uri=one block_availability_zone=2 read_timeout=3")
    rsp.stderr.should eq("")
  end

  context "account:use with good file" do
    it "should report success" do
      rsp = cptr("account:use foo")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Account 'foo' is now the default\n")
      rsp.exit_status.should be_exit(:success)
      ConfigHelper.value(:default_account).should eq("foo")
    end
  end

  context "account:use with bad file" do
    it "should report success" do
      rsp = cptr("account:add default auth_uri=one block_availability_zone=2 read_timeout=3")
      rsp.stderr.should eq("")

      rsp = cptr("account:use bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
      ConfigHelper.value('default_account').should be_nil
    end
  end

  after(:all) {reset_all()}
end

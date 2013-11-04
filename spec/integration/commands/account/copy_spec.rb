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

describe "Account copy" do
  before(:all) do
    ConfigHelper.use_tmp()
    AccountsHelper.use_tmp()
    rsp = cptr("account:add default auth_uri=one compute=2 read_timeout=3")
    rsp.stderr.should eq("")
    rsp = cptr("account:add foo auth_uri=two compute=3 read_timeout=4")
    rsp.stderr.should eq("")
  end

  context "account:copy with good file" do
    it "should report success" do
      rsp = cptr("account:copy foo bar")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Account 'foo' copied to 'bar'\n")
      rsp.exit_status.should be_exit(:success)
      AccountsHelper.value('bar', :credentials, :auth_uri).should eq("two")
      AccountsHelper.value('bar', :regions, :compute).should eq("3")
      AccountsHelper.value('bar', :options, :read_timeout).should eq("4")
    end
  end

  context "account:copy with bad file" do
    it "should report success" do
      rsp = cptr("account:copy bogus foo")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Error copying #{tmpdir}/.hpcloud/accounts/bogus to #{tmpdir}/.hpcloud/accounts/foo\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
      AccountsHelper.value('foo', :credentials, :auth_uri).should eq("two")
      AccountsHelper.value('foo', :regions, :compute).should eq("3")
      AccountsHelper.value('foo', :options, :read_timeout).should eq("4")
    end
  end

  after(:all) {reset_all()}
end

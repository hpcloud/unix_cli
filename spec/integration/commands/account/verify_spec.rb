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

describe "account:verify" do
  context "account:verify with good file" do
    it "should report success" do
      rsp = cptr("account:verify secondary")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Verifying 'secondary' account...\nAble to connect to valid account 'secondary'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "account:verify with nonexistent file" do
    it "should report error" do
      rsp = cptr("account:verify bogus")

      rsp.stderr.should eq("Could not find account file: #{ENV['HOME']}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "account:verify with bad file" do
    it "should report error" do
      rsp = cptr("account:copy secondary temporary")
      rsp.stderr.should eq("")
      rsp = cptr("account:update temporary secret_key=garbage")
      rsp.stderr.should eq("")

      rsp = cptr("account:verify temporary")

      rsp.stderr.should include("Account verification failed.")
      rsp.stdout.should eq("Verifying 'temporary' account...\n")
      rsp.exit_status.should be_exit(:general_error)
    end
  end
end

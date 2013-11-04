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

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "list command" do
  before(:all) do
    purge_container("mycontainer")
    cptr("remove -f mycontainer")
    cptr("containers:add mycontainer")
  end

  context "list" do
    it "should report success" do
      rsp = cptr("list")
      rsp.stderr.should eq("")
      rsp.stdout.should include("mycontainer")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "list container contents" do
    it "should report success" do
      rsp = cptr("list :mycontainer")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "containers" do
    it "should report success" do
      rsp = cptr('ls')
      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "containers" do
    it "should report success" do
      rsp = cptr('containers')
      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "containers:list" do
    it "should report success" do
      rsp = cptr('containers:list')
      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "containers:list --long" do
    it "should report success" do
      rsp = cptr('containers:list --long')
      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "containers:list --sync" do
    it "should report success" do
      rsp = cptr('containers:list --sync')
      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "list on object" do
    it "should report failure" do
      rsp = cptr("list :mycontainer/object.txt")

      rsp.stderr.should eq("Cannot find resource named ':mycontainer/object.txt'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "list container with valid avl" do
    it "should report success" do
      rsp = cptr("list :mycontainer -z region-a.geo-1")
      rsp.stderr.should eq("")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "list container with invalid avl" do
    it "should report error" do
      rsp = cptr("list :mycontainer -z blah")
      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("list :mycontainer -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      path = File.expand_path(File.dirname(__FILE__) + '/../../..')
      rsp.stderr.should eq("Could not find account file: #{path}/spec/tmp/home/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:each) {reset_all()}
  end

  after(:all) { purge_container('mycontainer') }
end

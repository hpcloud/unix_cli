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

describe "list command" do
  before(:all) do
    cptr("remove -f syncfrom")
    cptr("remove -f syncto")
    cptr("remove -f syncb")
    cptr("containers:add syncfrom")
    cptr("containers:add syncto")
    cptr("containers:add syncb -z #{REGION}")
    cptr("copy spec/fixtures/files/Matryoshka/Putin/Yeltsin :syncfrom")
  end

  context "containers:sync" do
    it "should report success" do
      rsp = cptr("location :syncto")
      location = rsp.stdout.strip

      rsp = cptr("containers:sync :syncto keyo")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Container :syncto using key 'keyo'\n")
      rsp.exit_status.should be_exit(:success)

      rsp = cptr("containers:sync :syncfrom keyo #{location}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Container :syncfrom using key 'keyo' to #{location}\n")
      rsp.exit_status.should be_exit(:success)

      rsp = cptr("list -c sname,synckey,syncto -d --sync")
      rsp.stderr.should eq("")
      rsp.stdout.should include("syncfrom,keyo,#{location}\n")
      rsp.stdout.should include("syncto,keyo,\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "containers:sync -z #{REGION}" do
    it "should report success" do
      rsp = cptr("location :syncb -z #{REGION}")
      location = rsp.stdout.strip

      rsp = cptr("containers:sync :syncb keyo -z #{REGION}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Container :syncb using key 'keyo'\n")
      rsp.exit_status.should be_exit(:success)

      rsp = cptr("containers:sync :syncto keyo #{location}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Container :syncto using key 'keyo' to #{location}\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "containers:sync :bogus keyo" do
    it "should report failure" do
      rsp = cptr("containers:sync :bogus keyo")

      rsp.stderr.should eq("Cannot find container ':bogus'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "containers:sync :syncto keyo -z #{REGION}" do
    it "should report success" do
      rsp = cptr("containers:sync :syncto keyo -z #{REGION}")
      rsp.stderr.should eq("")
      rsp.stdout.should eq("Container :syncto using key 'keyo'\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "containers:sync :syncto keyo -z bogus" do
    it "should report error" do
      rsp = cptr("containers:sync :syncto keyo -z bogus")
      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("containers:sync :syncto keyo -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      path = File.expand_path(File.dirname(__FILE__) + '/../../../..')
      rsp.stderr.should eq("Error syncing container: Could not find account file: #{path}/spec/tmp/home/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:each) {reset_all()}
  end

  after(:all) do
    cptr("remove -f syncfrom")
#    cptr("remove -f syncto")
#    cptr("remove -f syncb")
  end
end

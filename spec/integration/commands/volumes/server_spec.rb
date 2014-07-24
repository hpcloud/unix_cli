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

describe "volumes:server command" do
  before(:all) do
    @srv1 = ServerTestHelper.create("cli_test_srv1")
    @srv2 = ServerTestHelper.create("cli_test_srv2")
    @vol1 = VolumeTestHelper.create("cli_test_vol1")
    @vol1.attach(@srv1, '/dev/vdi')
    @vol2 = VolumeTestHelper.create("cli_test_vol2")
    @vol2.attach(@srv2, '/dev/vdg')
    @vol3 = VolumeTestHelper.create("cli_test_vol3")
    @vol3.attach(@srv1, '/dev/vdh')
    @vol1.fog.wait_for { in_use? }
    @vol2.fog.wait_for { in_use? }
    @vol3.fog.wait_for { in_use? }
  end

  context "when server volume with name" do
    it "should succeed" do
      rsp = cptr("volumes:server #{@srv1.name} #{@srv2.id}")

      rsp.stderr.should eq("")
      rsp.stdout.should match(".*name.*\\|.*server.*\\|.*device")

      rsp.stdout.should match(".*#{@vol1.name}.*\\|.*#{@srv1.name}.*\\|.*/dev/vdi.*\\|\n")
      rsp.stdout.should match(".*#{@vol2.name}.*\\|.*#{@srv2.name}.*\\|.*/dev/vdg.*\\|\n")
      rsp.stdout.should match(".*#{@vol3.name}.*\\|.*#{@srv1.name}.*\\|.*/dev/vdh.*\\|\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "volumes:server with valid avl" do
    it "should be successful" do
      rsp = cptr("volumes:server #{@srv1.name} -z #{REGION}")

      rsp.stderr.should eq("")
      rsp.stdout.should match(".*name.*\\|.*server.*\\|.*device")

      rsp.stdout.should match(".*#{@vol1.name}.*\\|.*#{@srv1.name}.*\\|.*/dev/vdi.*\\|\n")
      rsp.stdout.should match(".*#{@vol3.name}.*\\|.*#{@srv1.name}.*\\|.*/dev/vdh.*\\|\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "volumes:server with invalid avl" do
    it "should report error" do
      rsp = cptr("volumes:server #{@srv1.name} -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stderr.should include("Exception: Unable to retrieve endpoint service url for availability zone 'blah' from service catalog.")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { HP::Cloud::Connection.instance.clear_options() }
  end

  context "volumes:server with invalid volume" do
    it "should report error" do
      rsp = cptr("volumes:server bogus")

      rsp.stderr.should include("Cannot find a server matching 'bogus'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("volumes:server bogus -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end

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

describe "volumes:detach command" do
  before(:all) do
    @server = ServerTestHelper.create("cli_test_srv1")
  end

  context "when detach volume with name" do
    it "should succeed" do
      @vol1 = VolumeTestHelper.create("cli_test_vol1")
      @vol1.detach()
      @vol1.fog.wait_for { ready? }
      @vol1.attach(@server, '/dev/vdc').should be_true
      @vol1.fog.wait_for { in_use? }

      rsp = cptr("volumes:detach #{@vol1.name}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Detached volume '#{@vol1.name}' from '#{@server.name}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "volumes:detach with valid avl" do
    it "should be successful" do
      @vol2 = VolumeTestHelper.create("cli_test_vol2")
      @vol2.detach()
      @vol2.fog.wait_for { ready? }
      @vol2.attach(@server, '/dev/vdc').should be_true
      @vol2.fog.wait_for { in_use? }

      rsp = cptr("volumes:detach #{@vol2.name} -z #{REGION}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Detached volume '#{@vol2.name}' from '#{@server.name}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "volumes:detach with invalid avl" do
    it "should report error" do
      @vol3 = VolumeTestHelper.create("cli_test_vol3")
      @vol3.detach()
      @vol3.fog.wait_for { ready? }
      @vol3.attach(@server, '/dev/vdc').should be_true
      @vol3.fog.wait_for { in_use? }

      rsp = cptr("volumes:detach #{@vol3.name} -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'BlockStorage' service is activated for the appropriate availability zone.\n")
      rsp.stderr.should include("Exception: Unable to retrieve endpoint service url for availability zone 'blah' from service catalog.")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "volumes:detach with invalid volume" do
    it "should report error" do
      rsp = cptr("volumes:detach bogus")

      rsp.stderr.should include("Cannot find a volume matching 'bogus'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("volumes:detach something -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end

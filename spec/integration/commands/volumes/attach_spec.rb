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

describe "volumes:attach command" do
  before(:all) do
    @server = ServerTestHelper.create("cli_test_srv1")
    @vol1 = VolumeTestHelper.create("cli_test_vol1")
    @vol2 = VolumeTestHelper.create("cli_test_vol2")
    @vol3 = VolumeTestHelper.create("cli_test_vol3")
    if @vol1.fog.in_use?
      @vol1.detach()
      @vol1.fog.wait_for { ready? }
    end
    if @vol2.fog.in_use?
      @vol2.detach()
      @vol2.fog.wait_for { ready? }
    end
    if @vol3.fog.in_use?
      @vol3.detach()
      @vol3.fog.wait_for { ready? }
    end
  end

  context "when attaching volume with name" do
    it "should succeed" do
      rsp = cptr("volumes:attach #{@vol1.name} #{@server.name} /dev/vdf")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Attached volume '#{@vol1.name}' to '#{@server.name}' on '/dev/vdf'.\n")
      rsp.exit_status.should be_exit(:success)
    end

    after(:all) do
      @vol1.detach()
    end
  end

  context "when attaching in-use volume" do
    it "should fail" do
      rsp = cptr("volumes:attach #{@vol1.name} #{@server.name} /dev/vdk")

      rsp = cptr("volumes:attach #{@vol1.name} #{@server.name} /dev/vdl")

      rsp.stderr.should eq("Error attaching volume already in use '#{@vol1.name}'\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:conflicted)
    end

    after(:all) do
      @vol1.detach()
    end
  end

  context "volumes:attach with valid avl" do
    it "should be successful" do
      rsp = cptr("volumes:attach #{@vol2.name} -z region-b.geo-1 #{@server.name} /dev/vdg")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Attached volume '#{@vol2.name}' to '#{@server.name}' on '/dev/vdg'.\n")
      rsp.exit_status.should be_exit(:success)
    end

    after(:all) do
      @vol2.detach()
    end
  end

  context "volumes:attach with invalid avl" do
    it "should report error" do
      rsp = cptr("volumes:attach #{@vol3.name} #{@server.name} /dev/vdh -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { HP::Cloud::Connection.instance.clear_options() }
  end

  context "volumes:attach with invalid volume" do
    it "should report error" do
      rsp = cptr("volumes:attach bogus #{@server.name} /dev/vdi")

      rsp.stderr.should include("Cannot find a volume matching 'bogus'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("volumes:attach bogus #{@server.name} /dev/vdj -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end

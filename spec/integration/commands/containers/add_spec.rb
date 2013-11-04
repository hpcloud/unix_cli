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

describe "containers:add command" do

  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = storage_connection
  end

  context "when creating a new valid container" do
    it "should show success message" do
      rsp = cptr('containers:add my-added-container')

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Created container 'my-added-container'.\n")
      rsp.exit_status.should be_exit(:success)
      resp = @hp_svc.head_container('my-added-container').status.should eql(204)
    end
    
    after(:all) { purge_container('my-added-container') }
  end

  context "when creating a container which already exists" do
    it "should show exists message" do
      cptr('containers:add already-a-container')

      rsp = cptr('containers:add already-a-container')

      rsp.stderr.should eq("Container 'already-a-container' already exists.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:conflicted)
    end

    after(:all) { purge_container('already-a-container') }
  end
  
  context "when creating a container with invalid characters in the name" do
    it "should show error message" do
      rsp = cptr('containers:add my/container --force')

      rsp.stderr.should eq("Error adding container: Valid container names do not contain the '/' character: my/container\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
  end
  
  context "when creating a container whose name is valid, but not valid virtual host" do
    it "should present interactive prompt to verify behavior" do
      $stdout.should_receive(:print).with('Specified container name is not a valid virtualhost, continue anyway? [y/n] ')
      $stdin.should_receive(:gets).and_return('n')
      begin
        cli.send('containers:add', 'UPPERCASE')
      rescue SystemExit => system_exit # catch any exit calls
        exit_status = system_exit.status
      end
    end
  end

  context "add with valid avl" do
    it "should report success" do
      rsp = cptr('containers:add my-added-container2 -z region-b.geo-1')

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Created container 'my-added-container2'.\n")
      rsp.exit_status.should be_exit(:success)
    end
    after(:all) { purge_container('my-added-container2') }
  end

  context "add with invalid avl" do
    it "should report error" do
      rsp = cptr('containers:add my-added-container2 -z blah')

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("containers:add tainer -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Error adding container: Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end

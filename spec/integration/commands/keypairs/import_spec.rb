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

describe "keypairs:import" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = compute_connection
    @fake_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDb10XnajM1H7amPuG0P0lY34B1ZRQMTheX9lUBqMNnjzbY67LSP9cGUKaBEGlyboMavtY27vvG2qmFhzwcPsJBNcBhboTX4RCWyzFMp588tgkXq9RLdJ1DufysNvqvLc9V4N5ZjTl6soOjSYl71XVJs08LWXM4NljR1dT9kYb2nw== nova@use03147k5-eth0"
  end

  context "when importing a keypair" do
    before(:all) do
      @key_name = 'cli_test_key1'
    end

    it "should import" do
      @key_name = 'cli_test_key1'
      cptr("keypairs:rm #{@key_name}")

      rsp = cptr(["keypairs:import", "#{@key_name}", "#{@fake_public_key}"])

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Imported key pair '#{@key_name}'.\n")
      rsp.exit_status.should be_exit(:success)
      keypairs = @hp_svc.key_pairs.map {|kp| kp.name}
      keypairs.should include(@key_name)
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.name.should eql(@key_name)
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.fingerprint.should_not be_nil
    end

    it "should report key exists if imported again" do
      @key_name = 'cli_test_key1'
      rsp = cptr(["keypairs:import", "#{@key_name}", "#{@fake_public_key}"])

      rsp = cptr(["keypairs:import", "#{@key_name}", "#{@fake_public_key}"])

      rsp.stderr.should eq("Key pair '#{@key_name}' already exists.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end

    after(:all) do
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.destroy if keypair
    end
  end

  context "keypairs:import with valid avl" do
    before(:all) do
      @key_name = 'cli_test_key2'
    end

    it "should report success" do
      rsp = cptr(["keypairs:import", "#{@key_name}", "#{@fake_public_key}", '-z', 'region-b.geo-1'])
      rsp.stderr.should eq("")
      rsp.stdout.should include("Imported key pair '#{@key_name}'.\n")
      rsp.exit_status.should be_exit(:success)
    end

    after(:all) do
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.destroy if keypair
    end
  end

  context "keypairs:import with invalid avl" do
    it "should report error" do
      rsp = cptr(["keypairs:import", "#{@key_name}", "#{@fake_public_key}", "-z", "blah"])
      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("keypairs:import -a bogus nameo keyo")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end

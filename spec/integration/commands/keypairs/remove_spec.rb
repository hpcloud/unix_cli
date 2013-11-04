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

describe "keypairs:remove command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = compute_connection
    # delete keypairs if they existed
    del_keypair(@hp_svc, 'cli-del-200')
    del_keypair(@hp_svc, 'cli-del-201')
  end

  context "when deleting a keypair" do
    it "should show success message" do
      @key_name = 'cli-del-200'
      @keypair = @hp_svc.key_pairs.create(:name => @key_name)

      rsp = cptr("keypairs:remove #{@key_name}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed key pair '#{@key_name}'.\n")
      rsp.exit_status.should be_exit(:success)
      keypairs = @hp_svc.key_pairs.map {|k| k.name}
      keypairs.should_not include(@key_name)
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.should be_nil
    end
  end

  context "keypairs:remove with valid avl" do
    it "should report success" do
      @key_name = 'cli-del-201'
      @keypair = @hp_svc.key_pairs.create(:name => @key_name)

      rsp = cptr("keypairs:remove #{@key_name} -z region-b.geo-1")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed key pair '#{@key_name}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "keypairs:remove with invalid avl" do
    it "should report error" do
      @key_name = 'cli-del-201'

      rsp = cptr("keypairs:remove #{@key_name} -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("keypairs:remove -a bogus key_name")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end

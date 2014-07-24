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

describe "acl:revoke command" do

  before(:all) do
    @hp_svc = storage_connection
    @hp_svc.put_container('revoker')
    @hp_svc.put_object('revoker', 'foo.txt', read_file('foo.txt'))
  end

  context "when setting object" do
    it "should exit with message about not supported" do
      rsp = cptr("acl:revoke :revoker/foo.txt r")

      rsp.stderr.should eq("ACLs are only supported on containers (e.g. :container).\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_supported)
    end
  end

  context "when revoke private" do
    it "should exit with message about not supported" do
      rsp = cptr("acl:revoke :foo private")

      rsp.stderr.should eq("Use the acl:revoke command to revoke public read permissions\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:incorrect_usage)
    end
  end

  context "when revoke local" do
    it "should exit with message about not supported" do
      rsp = cptr("acl:revoke /foo/foo r")

      rsp.stderr.should eq("ACLs of local objects are not supported: /foo/foo\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:incorrect_usage)
    end
  end

  context "when revoke write public" do
    it "should exit with message about not supported" do
      rsp = cptr("acl:revoke :foo rw")

      rsp.stderr.should eq("You may not make an object writable by everyone\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_supported)
    end
  end

  context "when revoke local" do
    it "should exit with message about not supported" do
      rsp = cptr("acl:revoke :foo w")

      rsp.stderr.should eq("You may not make an object writable by everyone\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_supported)
    end
  end

  context "when acl string is not correct" do
    it "should exit with message about bad acl" do
      rsp = cptr("acl:revoke :foo_container blah-acl")

      rsp.stderr.should eq("Your permissions 'blah-acl' are not valid.\nValid settings are: r, rw, w\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:incorrect_usage)
    end
  end

  context "when revoke the ACL for a container" do
    it "should report success" do
      rsp = cptr("acl:grant :revoker r")
      rsp.stderr.should eq("")

      rsp = cptr("acl:revoke :revoker public-read")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Revoked public-read from :revoker\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "when revoke the ACL for an object" do
    it "should report success" do
      rsp = cptr("acl:grant :revoker r")
      rsp.stderr.should eq("")

      rsp = cptr("acl:revoke :revoker public-read")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Revoked public-read from :revoker\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "when revoke the ACL for an object" do
    it "should report success" do
      @username = AccountsHelper.get_username('secondary')
      rsp = cptr("acl:grant :revoker rw #{@username}")
      rsp.stderr.should eq("")

      rsp = cptr("acl:revoke :revoker rw #{@username}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Revoked rw for #{@username} from :revoker\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "acl:revoke with valid avl" do
    it "should report success" do
      rsp = cptr("acl:grant :revoker r -z #{REGION}")
      rsp.stderr.should eq("")

      rsp = cptr("acl:revoke :revoker r -z #{REGION}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Revoked public-read from :revoker\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "acl:revoke with invalid avl" do
    it "should report error" do
      rsp = cptr('acl:revoke :revoker public-read -z blah')

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("acl:revoke :revoker public-read -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end

  after(:all) do
    purge_container('revoker')
  end
end

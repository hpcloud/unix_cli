require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "acl:revoke command" do

  before(:all) do
    @hp_svc = storage_connection
    @hp_svc.put_container('revoker')
    @hp_svc.put_object('revoker', 'foo.txt', read_file('foo.txt'))
  end

  context "when revoke private" do
    it "should exit with message about not supported" do
      rsp = cptr("acl:revoke :foo/foo private")

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
      rsp = cptr("acl:revoke :foo/foo rw")

      rsp.stderr.should eq("You may not make an object writable by everyone\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_supported)
    end
  end

  context "when revoke local" do
    it "should exit with message about not supported" do
      rsp = cptr("acl:revoke :foo/foo w")

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
      rsp = cptr("acl:grant :revoker/foo.txt r")
      rsp.stderr.should eq("")

      rsp = cptr("acl:revoke :revoker/foo.txt public-read")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Revoked public-read from :revoker/foo.txt\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "when revoke the ACL for an object" do
    it "should report success" do
      @username = AccountsHelper.get_username('secondary')
      rsp = cptr("acl:grant :revoker/foo.txt rw #{@username}")
      rsp.stderr.should eq("")

      rsp = cptr("acl:revoke :revoker/foo.txt rw #{@username}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Revoked rw for #{@username} from :revoker/foo.txt\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "acl:revoke with valid avl" do
    it "should report success" do
      rsp = cptr("acl:grant :revoker/foo.txt r -z region-a.geo-1")
      rsp.stderr.should eq("")

      rsp = cptr('acl:revoke :revoker r -z region-a.geo-1')

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

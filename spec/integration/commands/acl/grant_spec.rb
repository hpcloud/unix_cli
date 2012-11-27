require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "acl:grant command" do

  before(:all) do
    @hp_svc = storage_connection
    @hp_svc.put_container('acl_container')
    @hp_svc.put_object('acl_container', 'foo.txt', read_file('foo.txt'))
  end

  context "when setting object" do
    it "should exit with message about not supported" do
      rsp = cptr("acl:grant :acl_container/foo.txt r")

      rsp.stderr.should eq("ACLs are only supported on containers (e.g. :container).\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_supported)
    end
  end

  context "when setting private" do
    it "should exit with message about not supported" do
      rsp = cptr("acl:grant :foo private")

      rsp.stderr.should eq("Use the acl:revoke command to revoke public read permissions\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:incorrect_usage)
    end
  end

  context "when setting local" do
    it "should exit with message about not supported" do
      rsp = cptr("acl:grant /foo/foo r")

      rsp.stderr.should eq("ACLs of local objects are not supported: /foo/foo\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:incorrect_usage)
    end
  end

  context "when setting write public" do
    it "should exit with message about not supported" do
      rsp = cptr("acl:grant :foo rw")

      rsp.stderr.should eq("You may not make an object writable by everyone\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_supported)
    end
  end

  context "when setting local" do
    it "should exit with message about not supported" do
      rsp = cptr("acl:grant :foo w")

      rsp.stderr.should eq("You may not make an object writable by everyone\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_supported)
    end
  end

  context "when acl string is not correct" do
    it "should exit with message about bad acl" do
      rsp = cptr("acl:grant :foo_container blah-acl")

      rsp.stderr.should eq("Your permissions 'blah-acl' are not valid.\nValid settings are: r, rw, w\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:incorrect_usage)
    end
  end

  context "when setting the ACL for a container" do
    it "should report success" do
      rsp = cptr("acl:grant :acl_container public-read")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("ACL for :acl_container updated to public-read.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "when setting the ACL for an object" do
    it "should report success" do
      rsp = cptr("acl:grant :acl_container public-read")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("ACL for :acl_container updated to public-read.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "when setting the ACL for an object" do
    it "should report success" do
      username = AccountsHelper.get_username('secondary')
      rsp = cptr("acl:grant :acl_container rw #{username}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("ACL for :acl_container updated to rw for #{username}.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "acl:grant with valid avl" do
    it "should report success" do
      rsp = cptr('acl:grant :acl_container public-read -z region-a.geo-1')

      rsp.stderr.should eq("")
      rsp.stdout.should eq("ACL for :acl_container updated to public-read.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "acl:grant with invalid avl" do
    it "should report error" do
      rsp = cptr('acl:grant :acl_container public-read -z blah')

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("acl:grant :acl_container public-read -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end

  after(:all) do
    purge_container('acl_container')
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Acl command (viewing acls)" do
  
  before(:all) do
    @hp_svc = storage_connection
    @hp_svc.directories.create(:key => 'acl_container')
    @hp_svc.directories.get('acl_container').files.create(:key => "foo.txt", :body => read_file('foo.txt'))
  end

  context "when resource is not correct" do
    it "should exit with message about not supported resource" do
      rsp = cptr('acl /foo/foo')

      rsp.stderr.should eq("ACL viewing is only supported for containers and objects. See `help acl`.\n")
      rsp.stdout.should eq("")
      rsp.exit_status be_exit(:general_error)
    end
  end

  context "when viewing the ACL for a private" do
    before(:all) do
      @dir = @hp_svc.directories.get('acl_container')
      @dir.public = false
      @dir.save
    end

    context "container" do
      it "should have 'private' permissions" do
        rsp = cptr('acl :acl_container')

        rsp.stderr.should eq("")
        rsp.stdout.should eql("private\n")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "object" do
      it "should have 'private' permissions" do
        rsp = cptr('acl :acl_container/foo.txt')

        rsp.stderr.should eq("")
        rsp.stdout.should eql("private\n")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "acl for container with valid avl" do
      it "should report success" do
        rsp = cptr('acl :acl_container -z region-a.geo-1')

        rsp.stderr.should eq("")
        rsp.stdout.should eql("private\n")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "acl for object with valid avl" do
      it "should report success" do
        rsp = cptr('acl :acl_container/foo.txt -z region-a.geo-1')

        rsp.stderr.should eq("")
        rsp.stdout.should eql("private\n")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "acl for container with invalid avl" do
      it "should report error" do
        rsp = cptr('acl :acl_container -z blah')

        rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.clear_options() }
    end

    context "acl for object with invalid avl" do
      it "should report error" do
        rsp = cptr('acl :acl_container/foo.txt -z blah')
        rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
        rsp.stdout.should eql("")
        rsp.exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.clear_options() }
    end
  end

  context "when viewing the ACL for a public" do
    before(:all) do
      @dir = @hp_svc.directories.get('acl_container')
      @dir.public = true
      @dir.save
    end

    context "container" do
      it "should have 'public' permissions" do
        rsp = cptr('acl :acl_container')

        rsp.stderr.should eq("")
        rsp.stdout.should eql("public-read\n")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "object" do
      it "should have 'public' permissions" do
        rsp = cptr('acl :acl_container/foo.txt')

        rsp.stderr.should eq("")
        rsp.stdout.should eql("public-read\n")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "acl for container with valid avl" do
      it "should report success" do
        rsp = cptr('acl :acl_container -z region-a.geo-1')

        rsp.stderr.should eq("")
        rsp.stdout.should eql("public-read\n")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "acl for object with valid avl" do
      it "should report success" do
        rsp = cptr('acl :acl_container/foo.txt -z region-a.geo-1')

        rsp.stderr.should eq("")
        rsp.stdout.should eql("public-read\n")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "acl for container with invalid avl" do
      it "should report error" do
        rsp = cptr('acl :acl_container -z blah')

        rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.clear_options() }
    end

    context "acl for object with invalid avl" do
      it "should report error" do
        rsp = cptr('acl :acl_container/foo.txt -z blah')

        rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.clear_options() }
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("acl :acl_container/foo.txt -a bogus")

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

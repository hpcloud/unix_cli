require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Remove command" do

  before(:all) do
    @hp_svc = storage_connection
  end

  context "removing an object from container" do

    def given_foo
      purge_container('my_container')
      create_container_with_files('my_container', 'foo.txt')
    end

    before(:all) do
      given_foo
    end

    context "when object does not exist" do
      it "should exit with object not found" do
        rsp = cptr('remove :my_container/nonexistant.txt')
        rsp.stderr.should eq("You don't have an object named ':my_container/nonexistant.txt'.\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:not_found)
      end
    end

    context "when removing an object that isn't controlled by the user" do
      #### Swift does not have acls, so it just cannot see the container
      it "should exit with access denied" do
        @file_name='spec/fixtures/files/Matryoshka/Putin/Medvedev.txt'
        cptr("containers:add -a secondary :notmycontainer")
        cptr("copy -a secondary #{@file_name} :notmycontainer")

        rsp = cptr("rm :notmycontainer/#{@file_name}")

        rsp.stderr.should eq("Cannot find container ':notmycontainer'.\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:not_found)
      end
    end

    context "when syntax is not correct" do
      it "should exit with message about bad syntax" do
        rsp = cptr("remove /foo/foo")
        rsp.stderr.should eql("Removal of local objects is not supported: /foo/foo\n")
        rsp.stdout.should eql("")
        rsp.exit_status.should be_exit(:incorrect_usage)
      end
    end

    context "when object and container exist" do
      it "should report success" do
        given_foo

        rsp = cptr("remove :my_container/foo.txt")

        rsp.stderr.should eql("")
        rsp.stdout.should eql("Removed ':my_container/foo.txt'.\n")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "remove --after" do
      it "should report success" do
        cptr("containers:add :aftertest")
        cptr("copy spec/fixtures/files/foo.txt :aftertest/after.txt")

        rsp = cptr("remove --after 1 :aftertest/after.txt")

        rsp.stderr.should eql("")
        rsp.stdout.should eql("Removing ':aftertest/after.txt' after 1 seconds.\n")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "remove --at" do
      it "should report success" do
        cptr("containers:add :attest")
        cptr("copy spec/fixtures/files/foo.txt :attest/at.txt")
        etime = Time.new.to_i + 30

        rsp = cptr("remove --at #{etime} :attest/at.txt")

        rsp.stderr.should eql("")
        rsp.stdout.should eql("Removing ':attest/at.txt' at #{etime} seconds of the epoch.\n")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "remove with valid avl" do
      it "should report success" do
        given_foo

        rsp = cptr("remove :my_container/foo.txt -z region-a.geo-1")

        rsp.stderr.should eq("")
        rsp.stdout.should eq("Removed ':my_container/foo.txt'.\n")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "remove with invalid avl" do
      it "should report error" do
        given_foo

        rsp = cptr("remove :my_container/foo.txt -z blah")

        rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.clear_options() }
    end

    after(:all) do
      purge_container('my_container')
    end
  end

  context "removing a container" do
    context "when container is not empty" do
      before(:each) do
        create_container_with_files('non_empty_container', 'foo.txt')
      end

      context "when negative answer" do
        it "should not remove container" do
          rsp = cptr('remove :non_empty_container')

          rsp.stderr.should eq("The container ':non_empty_container' is not empty. Please use -f option to force deleting a container with objects in it.\n")
          rsp.stdout.should eq("")
          rsp.exit_status.should be_exit(:conflicted)
        end
      end

      context "when force option is not used" do
        it "should not remove container" do
          rsp = cptr('remove :non_empty_container --force')

          rsp.stderr.should eq("")
          rsp.stdout.should eq("Removed ':non_empty_container'.\n")
          rsp.exit_status.should be_exit(:success)
        end
      end

      context "when force option is used" do
        it "should show success message" do
          rsp = cptr('remove -f :non_empty_container')

          rsp.stderr.should eq("")
          rsp.stdout.should eq("Removed ':non_empty_container'.\n")
          rsp.exit_status.should be_exit(:success)
          lambda{ @hp_svc.get_container('non_empty_container') }.should raise_error(Fog::Storage::HP::NotFound)
        end
      end

      after(:each) { purge_container('non_empty_container') }
    end
  end

  context "when object and container exist and object is at container level" do
    it "should report success" do
      rsp = cptr("remove -f :removetainer")
      rsp = cptr("containers:add :removetainer")
      rsp.stderr.should eq("")
      rsp = cptr("copy spec/fixtures/files/Matryoshka/Putin/Vladimir.txt :removetainer")
      rsp.stderr.should eq("")
      username = AccountsHelper.get_username('secondary')
      rsp = cptr("acl:grant :removetainer rw #{username}")
      rsp.stderr.should eq("")
      rsp = cptr("location :removetainer")
      rsp.stderr.should eq("")
      location=rsp.stdout.gsub("\n",'')

      rsp = cptr("remove #{location} -a secondary")

      rsp.stdout.should eq("")
      rsp.stderr.should eq("Removal of shared containers is not supported.\n")
      rsp.exit_status.should be_exit(:not_supported)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("remove -a bogus :non_empty_container")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end

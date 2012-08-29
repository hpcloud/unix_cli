require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "Acl:set command" do

  before(:all) do
    @hp_svc = storage_connection
    @hp_svc.put_container('acl_container')
    @hp_svc.put_object('acl_container', 'foo.txt', read_file('foo.txt'))
  end

  context "when resource is not correct" do
    it "should exit with message about not supported resource" do
      response = capture(:stderr){ HP::Cloud::CLI.start(['acl:set', '/foo/foo', 'private']) }
      response.should eql("Setting ACLs is only supported for containers and objects.\n")
    end
  end

  context "when acl string is not correct" do
    it "should exit with message about bad acl" do
      response = capture(:stderr){ HP::Cloud::CLI.start(['acl:set', ':foo_container', 'blah-acl']) }
      response.should eql("Your ACL 'blah-acl' is invalid.\nValid options are: private, public-read.\n")
    end
  end

  context "when setting the ACL for a container" do
    it "should report success" do
      response = capture(:stdout){ HP::Cloud::CLI.start(['acl:set', ':acl_container', 'public-read']) }
      response.should eql("ACL for :acl_container updated to public-read.\n")
    end
  end

  context "when setting the ACL for an object" do
    it "should report success" do
      response = capture(:stdout){ HP::Cloud::CLI.start(['acl:set', ':acl_container/foo.txt', 'public-read']) }
      response.should eql("ACL for :acl_container/foo.txt updated to public-read.\n")
    end
  end

  describe "with avl settings passed in" do
    context "acl:set with valid avl" do
      it "should report success" do
        response, exit_status = run_command('acl:set :acl_container public-read -z region-a.geo-1').stdout_and_exit_status
        response.should eql("ACL for :acl_container updated to public-read.\n")
        exit_status.should be_exit(:success)
      end
    end
    context "acl:set with invalid avl" do
      it "should report error" do
        response, exit_status = run_command('acl:set :acl_container public-read -z blah').stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.clear_options() }
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("acl:set :acl_container public-read -a bogus")

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

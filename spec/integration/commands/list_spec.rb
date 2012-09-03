require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "list command" do
  before(:all) do
    @hp_svc = storage_connection
    @hp_svc.put_container('my_container')
  end

  describe "with avl settings from config" do
    context "list" do
      it "should report success" do
        rsp = cptr("list")
        rsp.stderr.should eq("")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "list container contents" do
      it "should report success" do
        rsp = cptr("list :my_container")
        rsp.stderr.should eq("")
        rsp.stdout.should eq("my_container")
        rsp.exit_status.should be_exit(:success)
      end
    end
  end

  describe "with avl settings passed in" do
    context "list container with valid avl" do
      it "should report success" do
        rsp = cptr("list :my_container -z region-a.geo-1")
        rsp.stderr.should eq("")
        rsp.stdout.should eq("my_container")
        rsp.exit_status.should be_exit(:success)
      end
    end
    context "list container with invalid avl" do
      it "should report error" do
        rsp = cptr("list :my_container -z blah")
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

      rsp = cptr("list :my_container -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end

  after(:all) { purge_container('my_container') }
end

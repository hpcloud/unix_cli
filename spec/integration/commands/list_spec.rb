require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "list command" do
  before(:all) do
    purge_container("mycontainer")
    cptr("containers:add mycontainer")
  end

  context "list" do
    it "should report success" do
      rsp = cptr("list")
      rsp.stderr.should eq("")
      rsp.stdout.should include("mycontainer")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "list container contents" do
    it "should report success" do
      rsp = cptr("list :mycontainer")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "list on object" do
    it "should report failure" do
      rsp = cptr("list :mycontainer/object.txt")

      rsp.stderr.should eq("Cannot find resource named ':mycontainer/object.txt'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "list container with valid avl" do
    it "should report success" do
      rsp = cptr("list :mycontainer -z region-a.geo-1")
      rsp.stderr.should eq("")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "list container with invalid avl" do
    it "should report error" do
      rsp = cptr("list :mycontainer -z blah")
      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("list :mycontainer -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Exception reading ':mycontainer': Could not find account file: /home/terry/hp/unix_cli/spec/tmp/home/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:each) {reset_all()}
  end

  after(:all) { purge_container('mycontainer') }
end

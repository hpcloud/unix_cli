require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Servers command" do
  context "servers" do
    it "should report success" do
      rsp = cptr("servers")

      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "servers:list" do
    it "should report success" do
      rsp = cptr("servers:list")

      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "servers with valid avl" do
    it "should report success" do
      rsp = cptr("servers -z region-b.geo-1")

      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "servers with invalid avl" do
    it "should report error" do
      rsp = cptr('servers -z blah')
      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("servers -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end

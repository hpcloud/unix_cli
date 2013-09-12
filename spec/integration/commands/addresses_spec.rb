require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Addresses command" do
  context "addresses" do
    it "should report success" do
      rsp = cptr("addresses")
      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "addresses:list" do
    it "should report success" do
      rsp = cptr("addresses:list")
      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "addresses with valid avl" do
    it "should report success" do
      rsp = cptr("addresses -z region-b.geo-1")
      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "addresses with invalid avl" do
    it "should report error" do
      rsp = cptr('addresses -z blah')
      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Network' service is activated for the appropriate availability zone.\n")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("addresses -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end

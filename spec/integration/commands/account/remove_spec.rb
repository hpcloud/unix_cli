require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "Account remove" do
  before(:all) do
    ConfigHelper.use_tmp()
    AccountsHelper.use_tmp()
    rsp = cptr("account:add mike auth_uri=one")
    rsp.stderr.should eq("")
    rsp = cptr("account:add lanegan account_id=one auth_uri=two")
    rsp.stderr.should eq("")
  end

  context "account:remove bogus" do
    it "should report success" do
      rsp = cptr("account:remove bogus notthere")

      rsp.stderr.should eq("Error removing account file: #{AccountsHelper.tmp_dir()}/.hpcloud/accounts/bogus\nError removing account file: #{AccountsHelper.tmp_dir()}/.hpcloud/accounts/notthere\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "account:remove" do
    it "should report success" do
      rsp = cptr("account:remove mike")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed account 'mike'\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr("account:list")
      rsp.stdout.should eq("lanegan\n")
    end
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Account list" do
  before(:all) do
    ConfigHelper.use_tmp()
    AccountsHelper.use_tmp()
    rsp = cptr("account:add mike auth_uri=one")
    rsp.stderr.should eq("")
    rsp = cptr("account:add lanegan account_id=one auth_uri=two")
    rsp.stderr.should eq("")
  end

  context "account:list with no args" do
    it "should report success" do
      rsp = cptr("account:list")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("lanegan\nmike\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "account:list with account name" do
    it "should report success" do
      rsp = cptr("account:list mike")

      rsp.stderr.should eq("")
      rsp.stdout.should include("credentials:")
      rsp.stdout.should include("  auth_uri: one\n")
      rsp.stdout.should include("zones:")
      rsp.stdout.should include("options: {}")
      rsp.exit_status.should be_exit(:success)
    end
  end
  after(:all) {reset_all()}
end

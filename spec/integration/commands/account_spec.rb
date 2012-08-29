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
      rsp.stdout.should eq("---\n:credentials:\n  :auth_uri: one\n:zones:\n  :compute_availability_zone: az-1.region-a.geo-1\n  :storage_availability_zone: region-a.geo-1\n  :cdn_availability_zone: region-a.geo-1\n  :block_availability_zone: az-1.region-a.geo-1\n:options: {}\n")
      rsp.exit_status.should be_exit(:success)
    end
  end
  after(:all) {reset_all()}
end

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "Account use" do
  before(:all) do
    ConfigHelper.use_tmp()
    AccountsHelper.use_tmp()
    rsp = cptr("account:add foo auth_uri=two block_availability_zone=3 read_timeout=4")
    rsp.stderr.should eq("")
  end

  before(:all) do
    rsp = cptr("config:set default_account=default")
    rsp.stderr.should eq("")
    rsp = cptr("account:add default auth_uri=one block_availability_zone=2 read_timeout=3")
    rsp.stderr.should eq("")
  end

  context "account:use with good file" do
    it "should report success" do
      rsp = cptr("account:use foo")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Account 'foo' is now the default\n")
      rsp.exit_status.should be_exit(:success)
      ConfigHelper.value(:default_account).should eq("foo")
    end
  end

  context "account:use with bad file" do
    it "should report success" do
      rsp = cptr("account:add default auth_uri=one block_availability_zone=2 read_timeout=3")
      rsp.stderr.should eq("")

      rsp = cptr("account:use bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
      ConfigHelper.value('default_account').should be_nil
    end
  end

  after(:all) {reset_all()}
end

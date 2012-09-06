require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "Account copy" do
  before(:all) do
    ConfigHelper.use_tmp()
    AccountsHelper.use_tmp()
    rsp = cptr("account:add default auth_uri=one block_availability_zone=2 read_timeout=3")
    rsp.stderr.should eq("")
    rsp = cptr("account:add foo auth_uri=two block_availability_zone=3 read_timeout=4")
    rsp.stderr.should eq("")
  end

  context "account:copy with good file" do
    it "should report success" do
      rsp = cptr("account:copy foo bar")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Account 'foo' copied to 'bar'\n")
      rsp.exit_status.should be_exit(:success)
      AccountsHelper.value('bar', :credentials, :auth_uri).should eq("two")
      AccountsHelper.value('bar', :zones, :block_availability_zone).should eq("3")
      AccountsHelper.value('bar', :options, :read_timeout).should eq("4")
    end
  end

  context "account:copy with bad file" do
    it "should report success" do
      rsp = cptr("account:copy bogus foo")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Error copying #{tmpdir}/.hpcloud/accounts/bogus to #{tmpdir}/.hpcloud/accounts/foo\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
      AccountsHelper.value('foo', :credentials, :auth_uri).should eq("two")
      AccountsHelper.value('foo', :zones, :block_availability_zone).should eq("3")
      AccountsHelper.value('foo', :options, :read_timeout).should eq("4")
    end
  end

  after(:all) {reset_all()}
end

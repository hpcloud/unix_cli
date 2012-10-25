require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "Account add and update" do
  before(:all) do
    ConfigHelper.use_tmp()
    AccountsHelper.use_tmp()
  end

  context "account:add with good data" do
    it "should report success" do
      rsp = cptr("account:add foo auth_uri=one block_availability_zone=2 read_timeout=3")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Account 'foo' set auth_uri=one block_availability_zone=2 read_timeout=3\n")
      rsp.exit_status.should be_exit(:success)
      AccountsHelper.value('foo', :credentials, :auth_uri).should eq("one")
      AccountsHelper.value('foo', :zones, :block_availability_zone).should eq("2")
      AccountsHelper.value('foo', :options, :read_timeout).should eq("3")
    end
  end

  context "account:update with good data" do
    it "should report success" do
      rsp = cptr("account:update foo auth_uri=one block_availability_zone=2 read_timeout=3")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Account 'foo' set auth_uri=one block_availability_zone=2 read_timeout=3\n")
      rsp.exit_status.should be_exit(:success)
      AccountsHelper.value('foo', :credentials, :auth_uri).should eq("one")
      AccountsHelper.value('foo', :zones, :block_availability_zone).should eq("2")
      AccountsHelper.value('foo', :options, :read_timeout).should eq("3")
    end
  end

  context "account:add with credentials" do
    it "should report success" do
      rsp = cptr("account:add foo account_id=1 secret_key=2 auth_uri=3 tenant_id=4")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Account 'foo' set account_id=1 secret_key=2 auth_uri=3 tenant_id=4\n")
      rsp.exit_status.should be_exit(:success)
      AccountsHelper.value('foo', :credentials, :account_id).should eq("1")
      AccountsHelper.value('foo', :credentials, :secret_key).should eq("2")
      AccountsHelper.value('foo', :credentials, :auth_uri).should eq("3")
      AccountsHelper.value('foo', :credentials, :tenant_id).should eq("4")
    end
  end

  context "account:add with zones" do
    it "should report success" do
      rsp = cptr("account:add foo compute_availability_zone=1 storage_availability_zone=2 block_availability_zone=4")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Account 'foo' set compute_availability_zone=1 storage_availability_zone=2 block_availability_zone=4\n")
      rsp.exit_status.should be_exit(:success)
      AccountsHelper.value('foo', :zones, :compute_availability_zone).should eq("1")
      AccountsHelper.value('foo', :zones, :storage_availability_zone).should eq("2")
      AccountsHelper.value('foo', :zones, :block_availability_zone).should eq("4")
    end
  end

  context "account:add with options" do
    it "should report success" do
      rsp = cptr("account:add foo connect_timeout=1 read_timeout=2 write_timeout=3 ssl_verify_peer=4 ssl_ca_path=5 ssl_ca_file=6")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Account 'foo' set connect_timeout=1 read_timeout=2 write_timeout=3 ssl_verify_peer=4 ssl_ca_path=5 ssl_ca_file=6\n")
      rsp.exit_status.should be_exit(:success)
      AccountsHelper.value('foo', :options, :connect_timeout).should eq("1")
      AccountsHelper.value('foo', :options, :read_timeout).should eq("2")
      AccountsHelper.value('foo', :options, :write_timeout).should eq("3")
      AccountsHelper.value('foo', :options, :ssl_verify_peer).should eq("4")
      AccountsHelper.value('foo', :options, :ssl_ca_path).should eq("5")
      AccountsHelper.value('foo', :options, :ssl_ca_file).should eq("6")
    end
  end

  context "account:add with bad data" do
    it "should report error" do
      rsp = cptr("account:add foo bogus mistake=s=3")

      rsp.stderr.should eq("Invalid name value pair: 'bogus'\nInvalid name value pair: 'mistake=s=3'\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
  end
  after(:all) {reset_all()}
end

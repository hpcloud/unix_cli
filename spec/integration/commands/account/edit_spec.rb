require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "account:edit" do
  before(:all) do
    ConfigHelper.use_tmp()
    AccountsHelper.use_tmp()
  end

  context "without existing account" do
    it "without validation" do
      input = ['foo','bar','https://127.0.0.1/','111111','A','B','C']
      rsp = cptr('account:setup --no-validate', input)
      rsp.stdout.should eq(
        "****** Setup your HP Cloud Services hp account ******\n" +
        "Access Key Id: [] " +
        "Secret Key: [] " +
        "Auth Uri: [https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/] " +
        "Tenant Id: [] " +
        "Compute zone: [az-1.region-a.geo-1] " +
        "Storage zone: [region-a.geo-1] " +
        "Block zone: [az-1.region-a.geo-1] " +
        "Account credentials for HP Cloud Services have been saved.\n")
      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end

    it "with validation" do
      input = ['oof','rab','https://127.0.0.2/','222222','az-1.region-b.geo-1','region-b.geo-1','az-1.region-b.geo-1']
      rsp = cptr('account:setup', input)
      rsp.stdout.should eq(
        "****** Setup your HP Cloud Services hp account ******\n" +
        "Access Key Id: [foo] " +
        "Secret Key: [bar] " +
        "Auth Uri: [https://127.0.0.1/] " +
        "Tenant Id: [111111] " +
        "Compute zone: [A] " +
        "Storage zone: [region-b.geo-1] " +
        "Block zone: [az-1.region-b.geo-1] " +
        "Verifying your HP Cloud Services account...\n" +
        "Account credentials for HP Cloud Services have been saved.\n")
      rsp.stderr.should eq("Account verification failed. Error connecting to the service endpoint at: 'https://127.0.0.2/'. Please verify your account credentials. \n Exception: Connection refused - connect(2) (Errno::ECONNREFUSED)\n")
      rsp.exit_status.should be_exit(:general_error)
    end

    it "with account name" do
      input = ['mumford','sons','https://timshel/','322','A','B','C']
      rsp = cptr('account:setup --no-validate deluxe', input)
      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
      contents = AccountsHelper.contents('deluxe')
      contents.gsub!('"', "'")
      contents.should include(":credentials:")
      contents.should include("  :account_id: mumford")
      contents.should include("  :secret_key: sons")
      contents.should include("  :auth_uri: https://timshel/")
      contents.should include("  :tenant_id: '322'")
      contents.should include(":zones:")
      contents.should include("  :compute_availability_zone: A")
      contents.should include("  :storage_availability_zone: B")
      contents.should include("  :block_availability_zone: C")
      contents.should include(":options: {}")
    end

    it "over existing" do
      input = ['LaSera','SeesTheLight','https://please/','227','E','F','G']
      rsp = cptr('account:setup --no-validate deluxe', input)
      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
      contents = AccountsHelper.contents('deluxe')
      contents.gsub!('"', "'")
      contents.should include(":credentials:")
      contents.should include("  :account_id: LaSera")
      contents.should include("  :secret_key: SeesTheLight")
      contents.should include("  :auth_uri: https://please/")
      contents.should include("  :tenant_id: '227'")
      contents.should include(":zones:")
      contents.should include("  :compute_availability_zone: E")
      contents.should include("  :storage_availability_zone: F")
      contents.should include("  :block_availability_zone: G")
      contents.should include(":options: {}")
    end

    it "over existing" do
      input = ['LaSera','SeesTheLight','https://please/','227','1','2','3']
      rsp = cptr('account:edit --no-validate deluxe', input)
      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
      contents = AccountsHelper.contents('deluxe')
      contents.gsub!('"', "'")
      contents.should include(":credentials:")
      contents.should include("  :account_id: LaSera")
      contents.should include("  :secret_key: SeesTheLight")
      contents.should include("  :auth_uri: https://please/")
      contents.should include("  :tenant_id: '227'")
      contents.should include(":zones:")
      contents.should include("  :compute_availability_zone: '1'")
      contents.should include("  :storage_availability_zone: '2'")
      contents.should include("  :block_availability_zone: '3'")
      contents.should include(":options: {}")
    end
  end

  after(:all) {reset_all()}
end

describe "account:edit" do
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

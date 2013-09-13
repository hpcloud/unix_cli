require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "account:edit" do
  before(:all) do
    ConfigHelper.use_tmp()
    AccountsHelper.use_tmp()
  end

  context "without existing account" do
    it "without validation" do
      input = ['foo','bar','111111','https://127.0.0.1/']
      rsp = cptr('account:setup --no-validate', input)
      rsp.stdout.should eq(
        "****** Setup your HP Cloud Services hp account ******\n" +
        "Access Key Id: [] " +
        "Secret Key: [] " +
        "Project (aka Tenant) Id: [] " +
        "Identity (Auth) Uri: [https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/] " +
        "Account credentials for HP Cloud Services have been saved.\n")
      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end

    it "with validation" do
      input = ['oof','rab','222222','https://bogus.hp.com/']
      rsp = cptr('account:setup', input)
      rsp.stdout.should eq(
        "****** Setup your HP Cloud Services hp account ******\n" +
        "Access Key Id: [foo] " +
        "Secret Key: [bar] " +
        "Project (aka Tenant) Id: [111111] " +
        "Identity (Auth) Uri: [https://127.0.0.1/] " +
        "Verifying your HP Cloud Services account...\n" +
        "Account credentials for HP Cloud Services have been saved.\n")
      rsp.stderr.should match("Account verification failed. Error connecting to the service endpoint at: 'https://bogus.hp.com/'. Please verify your account credentials. \n Exception:.*")
      rsp.exit_status.should be_exit(:general_error)
    end

    it "with account name" do
      input = ['mumford','sons','322','https://timshel/']
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
      contents.should include(":regions: {}")
      contents.should include(":options: {}")
    end

    it "over existing" do
      input = ['LaSera','SeesTheLight','227','https://please/']
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
      contents.should include(":regions: {}")
      contents.should include(":options: {}")
    end

    it "over existing" do
      input = ['LaSera','SeesTheLight','227','https://please/']
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
      contents.should include(":regions: {}")
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
      rsp = cptr("account:add foo auth_uri=one network=2 read_timeout=3")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Account 'foo' set auth_uri=one network=2 read_timeout=3\n")
      rsp.exit_status.should be_exit(:success)
      AccountsHelper.value('foo', :credentials, :auth_uri).should eq("one")
      AccountsHelper.value('foo', :regions, :network).should eq("2")
      AccountsHelper.value('foo', :options, :read_timeout).should eq("3")
    end
  end

  context "account:update with good data" do
    it "should report success" do
      rsp = cptr("account:update foo auth_uri=one network=2 read_timeout=3")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Account 'foo' set auth_uri=one network=2 read_timeout=3\n")
      rsp.exit_status.should be_exit(:success)
      AccountsHelper.value('foo', :credentials, :auth_uri).should eq("one")
      AccountsHelper.value('foo', :regions, :network).should eq("2")
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

  context "account:add with regions" do
    it "should report success" do
      rsp = cptr("account:add foo compute=1 cdn=2 lbaas=4")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Account 'foo' set compute=1 cdn=2 lbaas=4\n")
      rsp.exit_status.should be_exit(:success)
      AccountsHelper.value('foo', :regions, :compute).should eq("1")
      AccountsHelper.value('foo', :regions, :cdn).should eq("2")
      AccountsHelper.value('foo', :regions, :lbaas).should eq("4")
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

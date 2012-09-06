require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "account:setup command" do
  before(:all) do
    ConfigHelper.use_tmp()
    AccountsHelper.use_tmp()
  end

  context "without existing account" do
    it "without validation" do
      input = ['foo','bar','https://127.0.0.1/','111111','A','B','C','D']
      rsp = cptr('account:setup --no-validate', input)
      rsp.stdout.should eq(
        "****** Setup your HP Cloud Services default account ******\n" +
        "Access Key Id: [] " +
        "Secret Key: [] " +
        "Auth Uri: [https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/] " +
        "Tenant Id: [] " +
        "Compute zone: [az-1.region-a.geo-1] " +
        "Storage zone: [region-a.geo-1] " +
        "CDN zone: [region-a.geo-1] " +
        "Block zone: [az-1.region-a.geo-1] " +
        "Account credentials for HP Cloud Services have been set up.\n")
      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end

    it "with validation" do
      input = ['oof','rab','https://127.0.0.2/','222222','az-1.region-b.geo-1','region-b.geo-1','region-b.geo-1','az-1.region-b.geo-1']
      rsp = cptr('account:setup', input)
      rsp.stdout.should eq(
        "****** Setup your HP Cloud Services default account ******\n" +
        "Access Key Id: [foo] " +
        "Secret Key: [bar] " +
        "Auth Uri: [https://127.0.0.1/] " +
        "Tenant Id: [111111] " +
        "Compute zone: [A] " +
        "Storage zone: [region-b.geo-1] " +
        "CDN zone: [region-b.geo-1] " +
        "Block zone: [az-1.region-b.geo-1] " +
        "Verifying your HP Cloud Services account...\n")
      rsp.stderr.should eq("Account setup failed. Error connecting to the service endpoint at: 'https://127.0.0.2/'. Please verify your account credentials. \n Exception: Connection refused - connect(2)\n")
      rsp.exit_status.should be_exit(:general_error)
    end

    it "with account name" do
      input = ['mumford','sons','https://timshel/','322','A','B','C','D']
      rsp = cptr('account:setup --no-validate deluxe', input)
      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
      AccountsHelper.contents('deluxe').should eq("---\n:credentials:\n  :account_id: mumford\n  :secret_key: sons\n  :auth_uri: https://timshel/\n  :tenant_id: '322'\n:zones:\n  :compute_availability_zone: A\n  :storage_availability_zone: B\n  :cdn_availability_zone: C\n  :block_availability_zone: D\n:options: {}\n")
    end

    it "over existing" do
      input = ['LaSera','SeesTheLight','https://please/','227','E','F','G','H']
      rsp = cptr('account:setup --no-validate deluxe', input)
      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
      AccountsHelper.contents('deluxe').should eq("---\n:credentials:\n  :account_id: LaSera\n  :secret_key: SeesTheLight\n  :auth_uri: https://please/\n  :tenant_id: '227'\n:zones:\n  :compute_availability_zone: E\n  :storage_availability_zone: F\n  :cdn_availability_zone: G\n  :block_availability_zone: H\n:options: {}\n")
    end

    it "over existing" do
      input = ['LaSera','SeesTheLight','https://please/','227','1','2','3','4']
      rsp = cptr('account:edit --no-validate deluxe', input)
      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
      AccountsHelper.contents('deluxe').should eq("---\n:credentials:\n  :account_id: LaSera\n  :secret_key: SeesTheLight\n  :auth_uri: https://please/\n  :tenant_id: '227'\n:zones:\n  :compute_availability_zone: '1'\n  :storage_availability_zone: '2'\n  :cdn_availability_zone: '3'\n  :block_availability_zone: '4'\n:options: {}\n")
    end
  end

  after(:all) {reset_all()}
end

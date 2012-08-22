require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "account:setup command" do
  context "without existing account" do
    before(:all) { AccountsHelper.use_tmp() }
  
    it "without validation" do
      input = ['foo','bar','https://127.0.0.1/','111111']
      rsp = cptr('account:setup --no-validate', input)
      rsp.stdout.should eq(
        "****** Setup your HP Cloud Services default account ******\n" +
        "Access Key Id: [] " +
        "Secret Key: [] " +
        "Auth Uri: [https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/] " +
        "Tenant Id: [] " +
        "Account credentials for HP Cloud Services have been set up.\n")
      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end

    it "with validation" do
      input = ['oof','rab','https://127.0.0.2/','222222']
      rsp = cptr('account:setup', input)
      rsp.stdout.should eq(
        "****** Setup your HP Cloud Services default account ******\n" +
        "Access Key Id: [foo] " +
        "Secret Key: [bar] " +
        "Auth Uri: [https://127.0.0.1/] " +
        "Tenant Id: [111111] " +
        "Verifying your HP Cloud Services account...\n")
      rsp.stderr.should eq("Account setup failed. Error connecting to the service endpoint at: 'https://127.0.0.2/'. Please verify your account credentials. \n Exception: Connection refused - connect(2)\n")
      rsp.exit_status.should be_exit(:general_error)
    end

    it "with account name" do
      input = ['mumford','sons','https://timshel/','322']
      rsp = cptr('account:setup --no-validate deluxe', input)
      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
      AccountsHelper.contents('deluxe').should eq("---\n:credentials:\n  :account_id: mumford\n  :secret_key: sons\n  :auth_uri: https://timshel/\n  :tenant_id: '322'\n:zones: {}\n:options: {}\n")
    end

    it "over existing" do
      input = ['LaSera','SeesTheLight','https://please/','227']
      rsp = cptr('account:setup --no-validate deluxe', input)
      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
      AccountsHelper.contents('deluxe').should eq("---\n:credentials:\n  :account_id: LaSera\n  :secret_key: SeesTheLight\n  :auth_uri: https://please/\n  :tenant_id: '227'\n:zones: {}\n:options: {}\n")
    end
  end
end

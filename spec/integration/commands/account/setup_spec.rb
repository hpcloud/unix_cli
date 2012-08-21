require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "account:setup command" do

  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) { AccountsHelper.use_tmp() }
  
  context "without existing account" do
  
    before(:all) { AccountsHelper.use_tmp() }
  
    it "should ask for account id, account key, endpoint and tenant_id" do
      $stdout.should_receive(:puts).with('****** Setup your HP Cloud Services default account ******')
      $stdout.should_receive(:print).with('Access Key Id: ')
      $stdin.should_receive(:gets).and_return('foo')
      $stdout.should_receive(:print).with('Secret Key: ')
      $stdin.should_receive(:gets).and_return('bar')
      $stdout.should_receive(:print).with('Auth Uri: [https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/] ')
      $stdin.should_receive(:gets).and_return('https://127.0.0.1/')
      $stdout.should_receive(:print).with('Tenant Id: ')
      $stdin.should_receive(:gets).and_return('111111')
      $stdout.should_receive(:puts).with('Verifying your HP Cloud Services account...')
      $stderr.should_receive(:puts).and_return('Account setup failed. Error connecting to the service endpoint at: https://127.0.0.1/. Please verify your account credentials. ')
      #$stderr.should_receive(:puts)
      begin
        cli.send('account:setup')
      rescue SystemExit => system_exit # catch any exit calls
        exit_status = system_exit.status
      end
    end

    it "should provide default endpoint and validate endpoint" do
      $stdout.should_receive(:puts).with('****** Setup your HP Cloud Services default account ******')
      $stdout.should_receive(:print).with('Access Key Id: ')
      $stdin.should_receive(:gets).and_return('foo')
      $stdout.should_receive(:print).with('Secret Key: ')
      $stdin.should_receive(:gets).and_return('bar')
      $stdout.should_receive(:print).with('Auth Uri: [https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/] ')
      $stdin.should_receive(:gets).and_return('https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/')
      $stdout.should_receive(:print).with('Tenant Id: ')
      $stdin.should_receive(:gets).and_return('111111')
      $stdout.should_receive(:puts).with('Verifying your HP Cloud Services account...')
      $stderr.should_receive(:puts).and_return('Account setup failed. Error connecting to the service endpoint at: "https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/". Please verify your account credentials.')
      #$stderr.should_receive(:puts)
      begin
        cli.send('account:setup')
      rescue SystemExit => system_exit # catch any exit calls
        exit_status = system_exit.status
      end
    end
    
    context "when successful" do
      
      it "should create account credential file"

    end
       
  end
  
end

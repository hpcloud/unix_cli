require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "account:setup command" do

  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) { setup_temp_home_directory }
  
  context "without existing account" do
  
    before(:all) { remove_account_files }
  
    it "should ask for account id, account key, endpoint and tenant_id" do
      $stdout.should_receive(:puts).with('****** Setup your HP Cloud Services account ******')
      $stdout.should_receive(:print).with('Account ID: ')
      $stdin.should_receive(:gets).and_return('foo')
      $stdout.should_receive(:print).with('Account Key: ')
      $stdin.should_receive(:gets).and_return('bar')
      $stdout.should_receive(:print).with('Auth Uri: [https://region-a.geo-1.objects.hpcloudsvc.com/v2.0/] ')
      $stdin.should_receive(:gets).and_return('https://127.0.0.1/')
      $stdout.should_receive(:print).with('Tenant Id: ')
      $stdin.should_receive(:gets).and_return('111111')
      $stdout.should_receive(:puts).with('Verifying your HP Cloud Services account...')
      $stderr.should_receive(:puts).with('Error connecting to the service endpoint at: https://127.0.0.1/.')
      begin
        cli.send('account:setup')
      rescue SystemExit => system_exit # catch any exit calls
        exit_status = system_exit.status
      end
    end

    it "should provide default endpoint and validate endpoint" do
      $stdout.should_receive(:puts).with('****** Setup your HP Cloud Services account ******')
      $stdout.should_receive(:print).with('Account ID: ')
      $stdin.should_receive(:gets).and_return('foo')
      $stdout.should_receive(:print).with('Account Key: ')
      $stdin.should_receive(:gets).and_return('bar')
      $stdout.should_receive(:print).with('Auth Uri: [https://region-a.geo-1.objects.hpcloudsvc.com/v2.0/] ')
      $stdin.should_receive(:gets).and_return('https://region-a.geo-1.objects.hpcloudsvc.com/v2.0/')
      $stdout.should_receive(:print).with('Tenant Id: ')
      $stdin.should_receive(:gets).and_return('111111')
      $stdout.should_receive(:puts).with('Verifying your HP Cloud Services account...')
      $stderr.should_receive(:puts).with('Error connecting to the service endpoint at: https://region-a.geo-1.objects.hpcloudsvc.com/v2.0/.')
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
  
  pending 'with existing account' do
    
    before(:all) { setup_account_file(:default) }
    
  end
  
end
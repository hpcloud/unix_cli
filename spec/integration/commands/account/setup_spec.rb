require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "account:setup command" do

  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) { setup_temp_home_directory }
  
  context "without existing account" do
  
    before(:all) { remove_account_files }
  
    it "should ask for account id, account key and endpoint" do
      $stdout.should_receive(:print).with('Account ID: ')
      $stdin.should_receive(:gets).and_return('account:user')
      $stdout.should_receive(:print).with('Account Key: ')
      $stdin.should_receive(:gets).and_return('pass')
      $stdout.should_receive(:print).with('Storage API Auth Uri: [https://region-a.geo-1.objects.hpcloudsvc.com/auth/v1.0/] ')
      $stdin.should_receive(:gets).and_return('https://127.0.0.1/')
      $stdout.should_receive(:print).with('Error connecting to the service endpoint at: https://127.0.0.1/. ')
      $stdin.should_receive(:gets).and_return('pass')
      begin
        cli.send('account:setup')
      rescue SystemExit => system_exit # catch any exit calls
        exit_status = system_exit.status
      end
    end

    it "should provide default endpoint and validate endpoint" do
      $stdout.should_receive(:print).with('Account ID: ')
      $stdin.should_receive(:gets).and_return('account:user')
      $stdout.should_receive(:print).with('Account Key: ')
      $stdin.should_receive(:gets).and_return('pass')
      $stdout.should_receive(:print).with('Storage API Auth Uri: [https://region-a.geo-1.objects.hpcloudsvc.com/auth/v1.0/] ')
      $stdin.should_receive(:gets).and_return('https://region-a.geo-1.objects.hpcloudsvc.com/auth/v1.0/')
      $stdout.should_receive(:print).with('Error connecting to the service endpoint at: https://region-a.geo-1.objects.hpcloudsvc.com/auth/v1.0/. ')
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
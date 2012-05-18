module HP
  module Cloud
    class CLI < Thor
    
      desc 'account:setup', "set up or modify your credentials"
      long_desc <<-DESC
  Setup or modify your account credentials. This is generally the first step
  in the process of using the HP Cloud Services command-line interface.
  
  You will need your Access Key Id, Secret Key and Tenant Id from the HP Cloud web site to
  set up your account. Optionally, you can specify your own endpoint to access,
  but in most cases you will want to use the default.  
  
  You can re-run this command to modify your settings at anytime.
      DESC
      method_option 'no-validate', :type => :boolean, :default => false,
                    :desc => "Don't verify account settings during setup"
      define_method "account:setup" do
        credentials = {}
        # remove the existing config directory
        Config.remove_config_directory
        # ask for credentials
        display "****** Setup your HP Cloud Services account ******"
        credentials[:account_id] = ask 'Access Key Id:'
        credentials[:secret_key] = ask 'Secret Key:'
        credentials[:auth_uri] = ask_with_default 'Auth Uri:',
                                      Config.settings[:default_auth_uri]
        credentials[:tenant_id] = ask 'Tenant Id:'
        # validate credentials
        unless options['no-validate']
          display "Verifying your HP Cloud Services account..."
          begin
            validate_account(credentials)
          rescue Exception => e
            error "Account setup failed. Error connecting to the service endpoint at: '#{credentials[:auth_uri]}'. Please verify your account credentials. \n Exception: #{e}"
          end
        end
        # update credentials and stash in config directory
        Config.update_credentials :default, credentials
        display "Account credentials for HP Cloud Services have been set up."
      end
    
    end
  end
end
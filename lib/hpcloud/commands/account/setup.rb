module HP
  module Cloud
    class CLI < Thor
    
      desc 'account:setup', "set up or modify your credentials"
      long_desc <<-DESC
  Setup or modify your account credentials. This is generally the first step
  in the process of using the HP Cloud command-line interface.
  
  You will need your Account ID and Account Key from the HP Cloud web site to
  set up your account. Optionally you can specify your own endpoint to access, 
  but in most cases you will want to use the default.  
  
  You can re-run this command to modify your settings.
      DESC
      method_option 'no-validate', :type => :boolean, :default => false,
                    :desc => "Don't verify account settings during setup"
      define_method "account:setup" do
        credentials = {}
        display "****** Setup your HP Cloud Services account ******"
        credentials[:account_id] = ask 'Account ID:'
        credentials[:secret_key] = ask 'Account Key:'
        credentials[:auth_uri] = ask_with_default 'Auth Uri:',
                                      Config.settings[:default_auth_uri]
        credentials[:tenant_id] = ask 'Tenant Id:'
        unless options['no-validate']
          begin
            display "Verifying your HP Cloud Services account..."
            begin
              connection_with(:storage, credentials).head_containers
            rescue NoMethodError
              error "Your HP Cloud Services account does not have the Storage service activated."
            end
            begin
              connection_with(:compute, credentials).list_servers
            rescue NoMethodError
              error "Your HP Cloud Services account does not have the Compute service activated."
            end
          rescue Excon::Errors::Forbidden, Excon::Errors::Unauthorized => e
            display_error_message(e)
          # remove once this is handled more globally
          rescue Excon::Errors::SocketError => e
            display_error_message(e)
          end
        end
        Config.update_credentials :default, credentials
        display "Account credentials for HP Cloud Services have been set up."
      end
    
    end
  end
end
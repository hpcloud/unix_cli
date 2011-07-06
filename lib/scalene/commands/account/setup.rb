module HP
  module Scalene
    class CLI < Thor
    
      desc 'account:setup', "set up or modify your credentials"
      long_desc <<-DESC
  Setup or modify your account credentials. This is generally the first step
  in the process of using the Scalene command-line interface. 
  
  You will need your Username and Password from the HP Scalene web site to
  set up your account. Optionally you can specify your own endpoint to access, 
  but in most cases you will want to use the default.  
  
  You can re-run this commmand to modify your settings.
      DESC
      method_option 'no-validate', :type => :boolean, :default => false, 
                    :desc => "Don't verify account settings during setup"
      define_method "account:setup" do
        credentials = {}
        credentials[:username] = ask 'Username:'
        credentials[:password] = ask 'Password:'
        credentials[:api_endpoint] = ask_with_default 'API endpoint:', 
                                      Config.settings[:default_api_endpoint]
        unless options['no-validate']
          begin
            display "Verifying your account..."
            connection_with(credentials).get_containers
          rescue Excon::Errors::Forbidden => e
            display_error_message(e)
          # remove once this is handled more globally
          rescue Excon::Errors::SocketError => e
            display_error_message(e)
          end
        end
        Config.update_credentials :default, credentials
        display "Account credentials have been set up."
      end
    
    end
  end
end
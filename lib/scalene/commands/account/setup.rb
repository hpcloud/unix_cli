module HP
  module Scalene
    class CLI < Thor
    
      desc 'account:setup', "set up or modify your credentials"
      long_desc "Setup or modify your account credientials.  This is generally the first step
                in the process of using the Scalene command-line interface.  Begin by retrieving your keys
                from the HP Scalene web site.  This command will ask you to enter your access_id and your secret_key.
                You can also set or modify the host and port of the HP endpoint.  You can re-run this commmand
                to modify your keys or other settings.
                \n\nExamples:
                \n\nscalene account:setup ==> Establishes your creds with HP Scalene CLI
                \n\nscalene account:setup --no-validate ==> Set/modify creds without calling the service to verify

                \n\nAliases: none
                \n\nNote: "
      method_option 'no-validate', :type => :boolean, :default => false, 
                    :desc => "Don't validate account during setup"
      define_method "account:setup" do
        credentials = {}
        credentials[:email] = ask 'Account email address:'
        credentials[:access_id] = ask 'Access ID:'
        credentials[:secret_key] = ask 'Secret key:'
        credentials[:api_endpoint] = ask_with_default 'API endpoint:', 
                                      Config.settings[:default_api_endpoint]
        unless options['no-validate']
          begin
            display "Verifying your account..."
            connection_with(credentials).get_service
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
module HPCloud
  class CLI < Thor
    
    desc 'account:setup', "set up or modify your credentials"
    method_option 'no-validate', :type => :boolean, :default => false, 
                  :desc => "Don't validate account during setup"
    define_method "account:setup" do
      credentials = {}
      credentials[:email] = ask 'Account email address:'
      credentials[:access_id] = ask 'Access ID:'
      credentials[:secret_key] = ask 'Secret key:'
      credentials[:host] = ask_with_default 'Host:', '16.49.184.31'
      credentials[:port] = ask_with_default 'Port:', 9232
      unless options['no-validate']
        begin
          puts "Verifying your account..."
          connection_with(credentials).get_service
        rescue Excon::Errors::Forbidden => e
          display_error_message(e)
        # remove once this is handled more globally
        rescue Excon::Errors::SocketError => e
          display_error_message(e)
        end
      end
      Config.update_credentials :default, credentials
      puts "Account credentials have been set up."
    end
    
  end
end
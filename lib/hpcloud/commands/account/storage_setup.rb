module HP
  module Cloud
    class CLI < Thor

      desc 'account:setup:storage', "setup or modify your storage services credentials"
      long_desc <<-DESC
  Setup or modify your account credentials for the HP Cloud Objects service. This is generally used to
  modify only the HP Cloud Storage account settings.

  You will need your Account ID and Account Key from the HP Cloud web site to
  set up your account. Optionally you can specify your own endpoint to access,
  but in most cases you will want to use the default.

  You can re-run this command to modify your settings.
      DESC
      method_option 'no-validate', :type => :boolean, :default => false,
                    :desc => "Don't verify account settings during setup"
      define_method "account:setup:storage" do
        credentials = {:storage => {}}
        display "****** Setup your HP Cloud Objects account ******"
        credentials[:storage][:account_id] = ask 'Account ID:'
        credentials[:storage][:secret_key] = ask 'Account Key:'
        credentials[:storage][:auth_uri] = ask_with_default 'Storage API Auth Uri:',
                                      Config.settings[:default_storage_auth_uri]
        unless options['no-validate']
          begin
            display "Verifying your HP Cloud Objects account..."
            connection_with(:storage, credentials[:storage]).head_containers
          rescue NoMethodError
            error "Please verify and try again."
          rescue Excon::Errors::Forbidden => e
            display_error_message(e)
          # remove once this is handled more globally
          rescue Excon::Errors::SocketError => e
            display_error_message(e)
          end
        end
        Config.update_credentials :default, credentials
        display "Account credentials for HP Cloud Objects have been set up."
      end

    end
  end
end
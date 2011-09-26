module HP
  module Cloud
    class CLI < Thor

      desc 'account:setup:compute', "setup or modify your compute services credentials"
      long_desc <<-DESC
  Setup or modify your account credentials for the HP Cloud Compute service. This is generally used to
  modify only the HP Cloud Compute account settings.

  You will need your Account ID and Account Key from the HP Cloud web site to
  set up your account. Optionally you can specify your own endpoint to access,
  but in most cases you will want to use the default.

  You can re-run this command to modify your settings.
      DESC
      method_option 'no-validate', :type => :boolean, :default => false,
                    :desc => "Don't verify account settings during setup"
      define_method "account:setup:compute" do
        credentials = {:compute => {}}
        display "****** Setup your HP Cloud Compute account ******"
        credentials[:compute][:account_id] = ask 'Account ID:'
        credentials[:compute][:secret_key] = ask 'Account Key:'
        credentials[:compute][:auth_uri] = ask_with_default 'Compute API Auth Uri:',
                                      Config.settings[:default_compute_auth_uri]
        unless options['no-validate']
          begin
            display "Verifying your HP Cloud Compute account..."
            #connection_with(:compute, credentials).list_servers
            connection_with(:compute, credentials[:compute]).describe_instances
          rescue NoMethodError
            error "Please verify and try again."
          rescue Excon::Errors::Forbidden, Excon::Errors::Unauthorized => e
            display_error_message(e)
          # remove once this is handled more globally
          rescue Excon::Errors::SocketError => e
            display_error_message(e)
          end
        end
        Config.update_credentials :default, credentials
        display "Account credentials for HP Cloud Compute have been set up."
      end

    end
  end
end
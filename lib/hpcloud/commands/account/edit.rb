require 'hpcloud/accounts'

module HP
  module Cloud
    class CLI < Thor

      desc 'account:edit [account_name]', "Edit your account credentials."
      long_desc <<-DESC
  Set up or modify your account credentials. If you do not specify an account name on the command line, the default account is updated.
  
  You  need your Access Key Id, Secret Key and Tenant Id from the HP Cloud web site to set up your account. Optionally, you can specify your own endpoint to access, but in most cases we recommend you use the default.  
  
  Availability zones typically have the format 'az-1.region-a.geo-1' or 'region-a.geo-1', depending on the service.  See your account API keys page to see your list of activated availability zones: https://console.hpcloud.com/account/api_keys
  
  'account:edit' prompts you for the following values:
  
  * Access Key Id
  * Secret Key 
  * Auth Uri
  * Tenant Id
  * Compute zone
  * Storage zone
  * CDN zone
  * Block zone

  You can re-run this command at any time to modify your settings.
  
Examples:
  hpcloud account:edit  # Edits the 'default' account settings.
      DESC
      method_option 'no-validate', :type => :boolean, :default => false,
                    :desc => "Don't verify account settings during edit"
      define_method "account:edit" do |*names|
        cli_command(options) {
          if names.empty?
            name = 'default'
          else
            if names.length == 1
              name = names[0]
            else
              error "Expected only one argument", :incorrect_usage
            end
          end
          accounts = HP::Cloud::Accounts.new()
          begin
            acct = accounts.read(name)
          rescue Exception => e
            acct = accounts.create(name)
          end
          cred = acct[:credentials]
          zones = acct[:zones]

          # ask for credentials
          display "****** Setup your HP Cloud Services #{name} account ******"
          cred[:account_id] = ask_with_default 'Access Key Id:', "#{cred[:account_id]}"
          cred[:secret_key] = ask_with_default 'Secret Key:', "#{cred[:secret_key]}"
          cred[:auth_uri] = ask_with_default 'Auth Uri:', "#{cred[:auth_uri]}"
          cred[:tenant_id] = ask_with_default 'Tenant Id:', "#{cred[:tenant_id]}"
          zones[:compute_availability_zone] = ask_with_default 'Compute zone:', "#{zones[:compute_availability_zone]}"
          accounts.rejigger_zones(zones)
          zones[:storage_availability_zone] = ask_with_default 'Storage zone:', "#{zones[:storage_availability_zone]}"
          zones[:cdn_availability_zone] = ask_with_default 'CDN zone:', "#{zones[:cdn_availability_zone]}"
          zones[:block_availability_zone] = ask_with_default 'Block zone:', "#{zones[:block_availability_zone]}"

          unless options['no-validate']
            display "Verifying your HP Cloud Services account..."
            begin
              Connection.instance.validate_account(cred)
            rescue Exception => e
              error_message "Account verification failed. Error connecting to the service endpoint at: '#{cred[:auth_uri]}'. Please verify your account credentials. \n Exception: #{e}", :general_error
            end
          end

          # update credentials and stash in config directory
          accounts.set_credentials(name, cred[:account_id], cred[:secret_key], cred[:auth_uri], cred[:tenant_id])
          accounts.set_zones(name, zones[:compute_availability_zone], zones[:storage_availability_zone], zones[:cdn_availability_zone], zones[:block_availability_zone])
          accounts.write(name)

          display "Account credentials for HP Cloud Services have been edited."
        }
      end
    end
  end
end

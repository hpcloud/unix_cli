require 'hpcloud/accounts'

module HP
  module Cloud
    class CLI < Thor

      map %w(account:add account:setup account:update) => 'account:edit'

      desc 'account:edit <account_name> [name_value_pair ...]', "Create or edit your account credentials."
      long_desc <<-DESC
  Create or edit your account credentials. If you do not specify an account name on the command line, the default account is updated.  If you do not specify name value pairs, you are prompted to input the account values.

  You  need your Access Key Id, Secret Key and Tenant Id from the HP Cloud web site to set up your account. Optionally, you can specify your own endpoint to access, but in most cases we recommend you use the default.
  
  Availability zones typically have the format 'az-1.region-a.geo-1' or 'region-a.geo-1', depending on the service.  See your account API keys page to see your list of activated availability zones: https://console.hpcloud.com/account/api_keys
  
  You can re-run this command at any time to modify your settings.

  The interactive mode prompts you for the following values:
  
  * Access Key Id
  * Secret Key 
  * Auth Uri
  * Tenant Id
  * Compute zone
  * Storage zone
  * Block zone

  The command line mode allows you to set the following values:
#{Accounts.get_known}
  
Examples:
  hpcloud account:setup # Create or edit the default account interactively:
  hpcloud account:edit  # Edit the default account settings interactively:
  hpcloud account:edit pro auth_uri='https://127.0.0.1/' block_availability_zone='az-2.region-a.geo-1' # Set the account credential authorization URI to `https://127.0.0.1\` and the block availability zone to `az-2.region-a.geo-1`:

Aliases: account:add, account:setup, account:update
      DESC
      method_option 'no-validate', :type => :boolean, :aliases => '-n',
                    :default => false,
                    :desc => "Don't verify account settings during edit"
      define_method "account:edit" do |*args|
        cli_command(options) {
          if args.empty?
            config = Config.new(true)
            name = config.get(:default_account)
          else
            name = args.shift
          end
          accounts = HP::Cloud::Accounts.new()
          if args.empty?
            begin
              acct = accounts.read(name)
              actionstring = "edited"
            rescue Exception => e
              acct = accounts.create(name)
              actionstring = "set up"
            end
            cred = acct[:credentials]
            zones = acct[:zones]

            # ask for credentials
            @log.display "****** Setup your HP Cloud Services #{name} account ******"
            cred[:account_id] = ask_with_default 'Access Key Id:', "#{cred[:account_id]}"
            cred[:secret_key] = ask_with_default 'Secret Key:', "#{cred[:secret_key]}"
            cred[:auth_uri] = ask_with_default 'Auth Uri:', "#{cred[:auth_uri]}"
            cred[:tenant_id] = ask_with_default 'Tenant Id:', "#{cred[:tenant_id]}"
            zones[:compute_availability_zone] = ask_with_default 'Compute zone:', "#{zones[:compute_availability_zone]}"
            accounts.rejigger_zones(zones)
            zones[:storage_availability_zone] = ask_with_default 'Storage zone:', "#{zones[:storage_availability_zone]}"
            zones[:block_availability_zone] = ask_with_default 'Block zone:', "#{zones[:block_availability_zone]}"

            unless options['no-validate']
              @log.display "Verifying your HP Cloud Services account..."
              begin
                Connection.instance.validate_account(cred)
              rescue Exception => e
                @log.error "Account verification failed. Error connecting to the service endpoint at: '#{cred[:auth_uri]}'. Please verify your account credentials. \n Exception: #{e}"
              end
            end

            # update credentials and stash in config directory
            accounts.set_credentials(name, cred[:account_id], cred[:secret_key], cred[:auth_uri], cred[:tenant_id])
            accounts.set_zones(name, zones[:compute_availability_zone], zones[:storage_availability_zone], zones[:block_availability_zone])
            accounts.write(name)

            @log.display "Account credentials for HP Cloud Services have been #{actionstring}."
          else
            acct = accounts.read(name, true)
            updated = ""
            args.each { |nvp|
              begin
                k, v = Config.split(nvp)
                accounts.set(name, k, v)
                updated += " " if updated.empty? == false
                updated += nvp
              rescue Exception => e
                @log.error(e.to_s)
              end
            }
            if updated.empty? == false
              accounts.write(name)
              @log.display "Account '#{name}' set " + updated
            end
          end
        }
      end
    end
  end
end

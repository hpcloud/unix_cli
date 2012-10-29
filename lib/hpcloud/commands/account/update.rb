require 'hpcloud/accounts'

module HP
  module Cloud
    class CLI < Thor
    
      map 'account:add' => 'account:update'

      desc 'account:update <account_name> <name_value_pair> ...', "Modify your account credentials, zones, or options."
      long_desc <<-DESC
  Add or update your account credentials, zones, or options.  You may specify one or more name value pairs to update on a single command line.  Valid settings include:
#{Accounts.get_known}

Availability zones typically have the format `az-1.region-a.geo-1` or `region-a.geo-1` depending on the service.  See your account API keys page to see your list of activated availability zones: https://console.hpcloud.com/account/api_keys
  
Examples:
  hpcloud account:update pro auth_uri='https://127.0.0.1/' block_availability_zone='region-a' # Set the account credential authorization URI to `https://127.0.0.1\` and the block availability zone to `region-a`:

Aliases: account:add
      DESC
      define_method "account:update" do |name, pair, *pairs|
        cli_command(options) {
          accounts = HP::Cloud::Accounts.new()
          acct = accounts.read(name, true)
          updated = ""
          pairs = [pair] + pairs
          pairs.each { |nvp|
            begin
              k, v = Config.split(nvp)
              accounts.set(name, k, v)
              updated += " " if updated.empty? == false
              updated += nvp
            rescue Exception => e
              error_message(e.to_s, :general_error)
            end
          }
          if updated.empty? == false
            accounts.write(name)
            display "Account '#{name}' set " + updated
          end
        }
      end
    end
  end
end

require 'hpcloud/accounts'

module HP
  module Cloud
    class CLI < Thor
    
      map 'account:update' => 'account:add'

      desc 'account:add', "modify your account credentials, zones, or options"
      long_desc <<-DESC
  Add or update account credentials, zones, or options.
  
Examples:
  hpcloud accout:add pro auth_uri='https://127.0.01/' block_availability_zone='region-a'

Alias: accout:update
      DESC
      define_method "account:add" do |name, pair, *pairs|

        cli_command(options) {
          accounts = HP::Cloud::Accounts.new()
          acct = accounts.read(name, true)
          updated = ""
          pairs = [pair] + pairs
          pairs.each { |nvp|
            kv = nvp.split('=')
            if kv.length != 2
              error_message("Invalid name value pair: '#{nvp}'", :general_error)
            else
              accounts.set(name, kv[0], kv[1])
              updated += " " if updated.empty? == false
              updated += nvp
            end
          }
          if updated.empty? == false
            accounts.write(name)
            display "Account #{name} set " + updated
          end
        }
      end
    end
  end
end

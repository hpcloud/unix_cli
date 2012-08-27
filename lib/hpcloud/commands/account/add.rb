require 'hpcloud/accounts'

module HP
  module Cloud
    class CLI < Thor
    
      map 'account:update' => 'account:add'

      desc 'account:add', "modify your account credentials, zones, or options"
      long_desc <<-DESC
  Add or update account credentials, zones, or options.  Valid settings include:
#{Accounts.get_known}
  
Examples:
  hpcloud account:add pro auth_uri='https://127.0.0.1/' block_availability_zone='region-a'

Alias: account:update
      DESC
      define_method "account:add" do |name, pair, *pairs|
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
            display "Account #{name} set " + updated
          end
        }
      end
    end
  end
end

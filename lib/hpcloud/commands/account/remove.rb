require 'hpcloud/accounts'

module HP
  module Cloud
    class CLI < Thor
    
      map %w(account:rm account:delete account:del) => 'account:remove'

      desc 'account:remove account_name [account_name ...]', "Remove accounts."
      long_desc <<-DESC
  Remove accounts.  You may specify one or more account to remove on the command line.
  
Examples:
  hpcloud account:remove useast uswest # Remove the `useast` and `uswest` accounts:

Aliases: account:rm, account:delete, account:del
      DESC
      define_method "account:remove" do |name, *names|
        cli_command(options) {
          accounts = HP::Cloud::Accounts.new()
          names = [name] + names
          names.each{ |name|
            sub_command {
              accounts.remove(name)
              @log.display("Removed account '#{name}'")
            }
          }
        }
      end
    end
  end
end

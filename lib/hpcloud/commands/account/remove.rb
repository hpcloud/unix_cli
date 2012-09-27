require 'hpcloud/accounts'

module HP
  module Cloud
    class CLI < Thor
    
      map %w(account:rm account:delete account:del) => 'account:remove'

      desc 'account:remove account_name [account_name ...]', "remove accounts"
      long_desc <<-DESC
  Remove accounts.  You may specify one or more account to remove on the command line.
  
Examples:
  hpcloud account:remove useast uswest # remove the useast and uswest accounts

Alias: account:rm, account:delete, account:del
      DESC
      define_method "account:remove" do |name, *names|
        cli_command(options) {
          accounts = HP::Cloud::Accounts.new()
          names = [name] + names
          names.each{ |name|
            begin
              accounts.remove(name)
              display("Removed account '#{name}'")
            rescue Exception => e
              error_message(e.to_s, :general_error)
            end
          }
        }
      end
    end
  end
end

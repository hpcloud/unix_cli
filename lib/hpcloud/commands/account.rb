require 'hpcloud/accounts'
require 'hpcloud/commands/account/copy'
require 'hpcloud/commands/account/edit'
require 'hpcloud/commands/account/remove'
require 'hpcloud/commands/account/setup'
require 'hpcloud/commands/account/update'
require 'hpcloud/commands/account/use'

module HP
  module Cloud
    class CLI < Thor
    
      map 'account:list' => 'account'

      desc 'account [account_name]', "list your accounts and account settings"
      long_desc <<-DESC
  List your accounts and your account settings.
  
Examples:
  hpcloud account
  hpcloud account:list
  hpcloud account:list useast

Aliases: account:list
      DESC
      def account(name=nil)
        cli_command(options) {
          accounts = HP::Cloud::Accounts.new()
          if name.nil?
            display accounts.list
          else
            begin
              acct = accounts.read(name)
              display acct.to_yaml.gsub(/---\n/,'').gsub(/^:/,'').gsub(/^[ ]*:/,'  ')
            rescue Exception => e
              error_message(e.to_s, :general_error)
            end
          end
        }
      end
    end
  end
end

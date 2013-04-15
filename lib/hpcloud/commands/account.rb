require 'hpcloud/accounts'
require 'hpcloud/commands/account/catalog'
require 'hpcloud/commands/account/copy'
require 'hpcloud/commands/account/edit'
require 'hpcloud/commands/account/remove'
require 'hpcloud/commands/account/setup'
require 'hpcloud/commands/account/use'
require 'hpcloud/commands/account/verify'

module HP
  module Cloud
    class CLI < Thor
    
      map 'account:list' => 'account'

      desc 'account [account_name]', "List your accounts and account settings."
      long_desc <<-DESC
  List your accounts and your account settings.
  
Examples:
  hpcloud account # List your accounts and account settings:
  hpcloud account:list # List your accounts and account settings:
  hpcloud account:list useast # List your accounts and account settings for domain `useast`:

Aliases: account:list
      DESC
      def account(name=nil)
        cli_command(options) {
          accounts = HP::Cloud::Accounts.new()
          if name.nil?
            config = Config.new(true)
            name = config.get(:default_account)
            listo = accounts.list
            @log.display listo.gsub(/^(#{name})$/, '\1 <= default')
          else
            sub_command {
              acct = accounts.read(name)
              @log.display acct.to_yaml.gsub(/---\n/,'').gsub(/^:/,'').gsub(/^[ ]*:/,'  ')
            }
          end
        }
      end
    end
  end
end

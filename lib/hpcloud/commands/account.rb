require 'hpcloud/accounts'
require 'hpcloud/commands/account/add'
require 'hpcloud/commands/account/remove'
require 'hpcloud/commands/account/setup'

module HP
  module Cloud
    class CLI < Thor
    
      map 'account:list' => 'account'

      desc 'account', "list your accounts and account settings"
      long_desc <<-DESC
  List your accounts and your account settings.
  
Examples:
  hpcloud account
  hpcloud account:list
  hpcloud account:list useast

Alias: account:list
      DESC
      define_method "account" do |name=nil|
        cli_command(options) {
          accounts = HP::Cloud::Accounts.new()
          if name.nil?
            display accounts.list
          else
            begin
              acct = accounts.read(name)
              display acct.to_yaml
            rescue Exception => e
              error_message(e.to_s, :general_error)
            end
          end
        }
      end
    end
  end
end

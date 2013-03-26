require 'hpcloud/accounts'

module HP
  module Cloud
    class CLI < Thor
    
      desc 'account:use <account_to_use>', "Set the named account to the default account."
      long_desc <<-DESC
  Use the specified account as your default account.  Any command executed without the `-a` account_name option uses this account.
  
Examples:
  hpcloud account:use useast # Set the default account to `useast`:
      DESC
      define_method "account:use" do |name|
        cli_command(options) {
          HP::Cloud::Accounts.new().read(name)
          config = Config.new(true)
          config.set(:default_account, name)
          config.write()
          @log.display("Account '#{name}' is now the default")
        }
      end
    end
  end
end

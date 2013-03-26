require 'hpcloud/accounts'

module HP
  module Cloud
    class CLI < Thor
    
      desc 'account:copy <from_account> <to_account>', "Copy account data to the specified account."
      long_desc <<-DESC
  The copy command overwrites the destination account with the source account information.
  
Examples:
  hpcloud account:copy useast backup  # Copy account `useast` to account `backup`:
      DESC
      define_method "account:copy" do |src, dest|
        cli_command(options) {
          accounts = HP::Cloud::Accounts.new()
          accounts.copy(src, dest)
          @log.display("Account '#{src}' copied to '#{dest}'")
        }
      end
    end
  end
end

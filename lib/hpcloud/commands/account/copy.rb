require 'hpcloud/accounts'

module HP
  module Cloud
    class CLI < Thor
    
      desc 'account:copy', "Copy account data to specified account"
      long_desc <<-DESC
  The copy command will overwrite the destination account with the source.
  
Examples:
  hpcloud account:copy useast backup
      DESC
      define_method "account:copy" do |src, dest|
        cli_command(options) {
          accounts = HP::Cloud::Accounts.new()
          accounts.copy(src, dest)
          display("Account '#{src}' copied to '#{dest}'")
        }
      end
    end
  end
end

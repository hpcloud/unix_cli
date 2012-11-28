require 'hpcloud/accounts'

module HP
  module Cloud
    class CLI < Thor
    
      desc 'account:verify <account_to_verify>', "Verify the credentials of the specified account."
      long_desc <<-DESC
  Verify the credentials of an account.
  
Examples:
  hpcloud account:verify useast # Verify the `useast` account credentials:
      DESC
      define_method "account:verify" do |name|
        cli_command(options) {
          acct = HP::Cloud::Accounts.new().read(name)
          display "Verifying '#{name}' account..."
          begin
            Connection.instance.validate_account(acct[:credentials])
            display "Connected to '#{name}' successfully"
          rescue Exception => e
            error_message "Account verification failed. Error connecting to the service endpoint at: '#{acct[:credentials][:auth_uri]}'. Please verify your account credentials. \n Exception: #{e}", :general_error
          end
        }
      end
    end
  end
end

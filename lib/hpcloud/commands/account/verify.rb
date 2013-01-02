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
      method_option :debug, :type => :string, :alias => '-x',
                    :desc => 'Debug logging 1,2,3,...'
      define_method "account:verify" do |name|
        cli_command(options) {
          acct = HP::Cloud::Accounts.new().read(name)
          @log.display "Verifying '#{name}' account..."
          begin
            Connection.instance.validate_account(acct[:credentials])
            @log.display "Able to connect to valid account '#{name}'."
          rescue Exception => e
            e = ErrorResponse.new(e).to_s
            @log.error "Account verification failed. Error connecting to the service endpoint at: '#{acct[:credentials][:auth_uri]}'. Please verify your account credentials. \n Exception: #{e}"
          end
        }
      end
    end
  end
end

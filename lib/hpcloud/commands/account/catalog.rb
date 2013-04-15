require 'hpcloud/accounts'

module HP
  module Cloud
    class CLI < Thor
    
      desc 'account:catalog <account_to_catalog>', "Print the service catalog of the specified account."
      long_desc <<-DESC
  Print the service catalog of the specified account.
  
Examples:
  hpcloud account:catalog useast # Print the service catalog of `useast`:
      DESC
      method_option :debug, :type => :string, :alias => '-x',
                    :desc => 'Debug logging 1,2,3,...'
      define_method "account:catalog" do |name|
        cli_command(options) {
          HP::Cloud::Accounts.new().read(name)
          @log.display "Verifying '#{name}' account..."
          begin
            rsp = Connection.instance.validate_account(name)
            @log.display "Service catalog '#{name}':"
            @log.display rsp.to_s
          rescue Exception => e
            unless options[:debug].nil?
              puts e.backtrace
            end
            e = ErrorResponse.new(e).to_s
            @log.error "Account verification failed. Please check your account credentials. \n Exception: #{e}"
          end
        }
      end
    end
  end
end

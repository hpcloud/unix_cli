require 'yaml'
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
          @log.display "Service catalog '#{name}':"
          HP::Cloud::Accounts.new().read(name)
          begin
            rsp = Connection.instance.validate_account(name)
            @log.display rsp[:service_catalog].to_yaml
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

require 'yaml'
require 'hpcloud/accounts'

module HP
  module Cloud
    class CLI < Thor
    
      desc 'account:catalog <account_to_catalog> [service]', "Print the service catalog of the specified account."
      long_desc <<-DESC
  Print the service catalog of the specified account.  Optionally, you may specify a particular service to print such as "Compute".
  
Examples:
  hpcloud account:catalog useast # Print the service catalog of `useast`:
  hpcloud account:catalog useast Compute # Print the compute catalog of `useast`:
      DESC
      method_option :debug, :type => :string, :alias => '-x',
                    :desc => 'Debug logging 1,2,3,...'
      define_method "account:catalog" do |name, *service|
        cli_command(options) {
          @log.display "Service catalog '#{name}':"
          HP::Cloud::Accounts.new().read(name)
          begin
            @log.display Connection.instance.catalog(name, service)
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

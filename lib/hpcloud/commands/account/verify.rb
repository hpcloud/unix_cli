# encoding: utf-8
#
# © Copyright 2013 Hewlett-Packard Development Company, L.P.
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'hpcloud/accounts'

module HP
  module Cloud
    class CLI < Thor
    
      desc 'account:verify <account_to_verify>', "Verify the credentials of the specified account."
      long_desc <<-DESC
  Verify the credentials of an account.
  
Examples:
  hpcloud account:verify useast # Verify the `useast` account credentials
      DESC
      method_option :debug, :type => :string, :alias => '-x',
                    :desc => 'Debug logging 1,2,3,...'
      define_method "account:verify" do |name|
        cli_command(options) {
          HP::Cloud::Accounts.new().read(name)
          @log.display "Verifying '#{name}' account..."
          begin
            Connection.instance.validate_account(name)
            @log.display "Able to connect to valid account '#{name}'."
          rescue Exception => e
            unless options[:debug].nil?
              puts e.backtrace
            end
            e = ErrorResponse.new(e).to_s
            @log.error "Account verification failed. Please verify your account credentials. \n Exception: #{e}"
          end
        }
      end
    end
  end
end

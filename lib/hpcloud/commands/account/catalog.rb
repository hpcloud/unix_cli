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

require 'yaml'
require 'hpcloud/accounts'

module HP
  module Cloud
    class CLI < Thor
    
      desc 'account:catalog <account_to_catalog> [service]', "Print the service catalog of the specified account."
      long_desc <<-DESC
  Print the service catalog of the specified account.  Optionally, you may specify a particular service to print such as `Compute`.

  You can then configure the catalog for your account with hpcloud account:edit catalog_<service>=<name> so that
   the cli knows how to talk with your particular cloud implementation. For example:
   hpcloud account:edit useast catalog_compute=nova
   See hpcloud help account:edit for more details.

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
            cata = Connection.instance.catalog(name, service)
            @log.display cata.to_yaml.gsub(/--- \n/,'').gsub(/\{\}/,'').gsub(/\n\n/, "\n")
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

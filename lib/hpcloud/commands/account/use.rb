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
    
      desc 'account:use <account_to_use>', "Set the named account to the default account."
      long_desc <<-DESC
  Use the specified account as your default account.  Any command executed without the `-a` account_name option uses this account.
  
Examples:
  hpcloud account:use useast # Set the default account to `useast`
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

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
    
      map %w(account:rm account:delete account:del) => 'account:remove'

      desc 'account:remove account_name [account_name ...]', "Remove accounts."
      long_desc <<-DESC
  Remove accounts.  You may specify one or more account to remove on the command line.
  
Examples:
  hpcloud account:remove useast uswest # Remove the `useast` and `uswest` accounts

Aliases: account:rm, account:delete, account:del
      DESC
      define_method "account:remove" do |name, *names|
        cli_command(options) {
          accounts = HP::Cloud::Accounts.new()
          names = [name] + names
          names.each{ |name|
            sub_command {
              accounts.remove(name)
              @log.display("Removed account '#{name}'")
            }
          }
        }
      end
    end
  end
end

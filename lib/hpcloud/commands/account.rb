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
require 'hpcloud/commands/account/catalog'
require 'hpcloud/commands/account/copy'
require 'hpcloud/commands/account/edit'
require 'hpcloud/commands/account/remove'
require 'hpcloud/commands/account/setup'
require 'hpcloud/commands/account/tenants'
require 'hpcloud/commands/account/use'
require 'hpcloud/commands/account/verify'

module HP
  module Cloud
    class CLI < Thor
    
      map 'account:list' => 'account'

      desc 'account [account_name]', "List your accounts and account settings."
      long_desc <<-DESC
  List your accounts and your account settings.
  
Examples:
  hpcloud account # List your accounts and account settings
  hpcloud account:list # List your accounts and account settings
  hpcloud account:list useast # List your accounts and account settings for domain `useast`

Aliases: account:list
      DESC
      def account(name=nil)
        cli_command(options) {
          accounts = HP::Cloud::Accounts.new()
          if name.nil?
            config = Config.new(true)
            name = config.get(:default_account)
            listo = accounts.list
            @log.display listo.gsub(/^(#{name})$/, '\1 <= default')
          else
            sub_command {
              acct = accounts.read(name)
              @log.display acct.to_yaml.gsub(/---\n/,'').gsub(/^:/,'').gsub(/^[ ]*:/,'  ')
            }
          end
        }
      end
    end
  end
end

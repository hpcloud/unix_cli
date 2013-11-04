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

require 'hpcloud/commands/dns/add'
require 'hpcloud/commands/dns/remove'
require 'hpcloud/commands/dns/records'
require 'hpcloud/commands/dns/servers'
require 'hpcloud/commands/dns/update'
require 'hpcloud/dnss'

module HP
  module Cloud
    class CLI < Thor

      map 'dns:list' => 'dns'
    
      desc 'dns [name_or_id ...]', "List the DNS domains."
      long_desc <<-DESC
  Lists all the DNS domains that are associated with the account. The list begins with identifier and contains name, TTL, serial number, email and time created.  Optionally, you can filter the list by specifying name or ID.

Examples:
  hpcloud dns            # List all dns domains
  hpcloud dns 421e8cbf   # List dns domain with id `421e8cbf`
  hpcloud dns test.com.  # List dns domain `test.com.`

Aliases: dns:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      def dns(*arguments)
        cli_command(options) {
          dnss = Dnss.new
          if dnss.empty?
            @log.display "You currently have no DNS domains, use `#{selfname} dns:add <name>` to create one."
          else
            ray = dnss.get_array(arguments)
            if ray.empty?
              @log.display "There are no DNS domains that match the provided arguments"
            else
              Tableizer.new(options, DnsHelper.get_keys(), ray).print
            end
          end
        }
      end
    end
  end
end

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

require 'hpcloud/commands/dns/add.rb'
require 'hpcloud/commands/dns/remove.rb'
require 'hpcloud/commands/dns/update.rb'
require 'hpcloud/dnss'

module HP
  module Cloud
    class CLI < Thor

      desc 'dns:servers <name_or_id>', "List the servers associated with the DNS domain."
      long_desc <<-DESC
  Lists servers associated with the DNS domain specified by name or ID.

Examples:
  hpcloud dns:servers 421e8cbf   # List servers for the DNS domain with ID `421e8cbf`
  hpcloud dns:servers test.com.  # List servers for the DNS domain `test.com.`
      DESC
      CLI.add_report_options
      CLI.add_common_options
      define_method "dns:servers" do |name_or_id|
        cli_command(options) {
          dns = Dnss.new.get(name_or_id)
          if dns.is_valid? == false
            @log.fatal dns.cstatus
          end
          ray = dns.servers
          if ray.empty?
            @log.display "There are no servers associated with this DNS domain"
          else
            Tableizer.new(options, dns.server_keys, ray).print
          end
        }
      end
    end
  end
end

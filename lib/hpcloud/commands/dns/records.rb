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

require 'hpcloud/commands/dns/records/add.rb'
require 'hpcloud/commands/dns/records/remove.rb'
require 'hpcloud/commands/dns/records/update.rb'
require 'hpcloud/dnss'

module HP
  module Cloud
    class CLI < Thor

      desc 'dns:records <name_or_id>', "List the records associated with the DNS domain."
      long_desc <<-DESC
  Lists records associated with the DNS domain specified by name or ID.

Examples:
  hpcloud dns:records 421e8cbf   # List records for DNS domain with ID `421e8cbf`
  hpcloud dns:records test.com.  # List records for DNS domain `test.com`
      DESC
      CLI.add_report_options
      CLI.add_common_options
      define_method "dns:records" do |name_or_id|
        cli_command(options) {
          dns = Dnss.new.get(name_or_id)
          if dns.is_valid? == false
            @log.fatal dns.cstatus
          end
          ray = dns.records
          if ray.empty?
            @log.display "There are no records associated with this DNS domain"
          else
            Tableizer.new(options, dns.record_keys, ray).print
          end
        }
      end
    end
  end
end

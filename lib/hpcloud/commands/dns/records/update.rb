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

module HP
  module Cloud
    class CLI < Thor

      desc "dns:records:update <domain> <id> <type> <data>", "Update a DNS record."
      long_desc <<-DESC
  Update a DNS record to the specified domain with the given id, type and data.

Examples:
  hpcloud dns:records:update mydomain.com. www.mydomain.com. A 10.0.0.1 # Update a DNS domain `mydomain.com` record `A` for `www.mydomain.com` pointing to address 10.0.0.1
      DESC
      CLI.add_common_options
      define_method "dns:records:update" do |domain, id, type, data|
        cli_command(options) {
          dns = Dnss.new.get(domain)
          unless dns.is_valid?
            @log.fatal dns.cstatus
          end
          record = dns.update_record(id, type, data)
          unless record.nil?
            @log.display "Updated DNS record '#{id}'."
          else
            @log.error "Cannot find DNS record '#{id}'."
          end
        }
      end
    end
  end
end

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

      desc "dns:records:add <domain> <name> <type> <data> [priority]", "Add a DNS record."
      long_desc <<-DESC
  Add a DNS record to the specified domain with the given name, type and data.  Optionally, a priority may be added.

Examples:
  hpcloud dns:records:add mydomain.com. www.mydomain.com. A 10.0.0.1 # Create a DNS record for domain `mydomain.com` and `A` record for `www.mydomain.com` pointing to address 10.0.0.1.
      DESC
      CLI.add_common_options
      define_method "dns:records:add" do |domain, name, type, data, *priority|
        cli_command(options) {
          dns = Dnss.new.get(domain)
          unless dns.is_valid?
            @log.fatal dns.cstatus
          end
          priority = priority[0]
          record = dns.create_record(name, type, data, { :priority => priority.to_i })
          if record.nil?
            @log.fatal dns.cstatus
          end
          @log.display "Created dns record '#{name}' with id '#{record[:id]}'."
        }
      end
    end
  end
end

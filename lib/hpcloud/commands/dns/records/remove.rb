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

      desc "dns:records:remove <domain> <id ...>", "Remove a DNS record."
      long_desc <<-DESC
  Remove a DNS record to the specified domain.  Records may be specified by identifier.

Examples:
  hpcloud dns:records:remove mydomain.com. www.mydomain.com. # Remove record `www.mydomain.com` from the domain `mydomain.com`.
      DESC
      CLI.add_common_options
      define_method "dns:records:remove" do |domain, *ids|
        cli_command(options) {
          dns = Dnss.new.get(domain)
          unless dns.is_valid?
            @log.fatal dns.cstatus
          end
          ids.each { |oneid|
            sub_command("removing DNS record") {
              if dns.delete_record(oneid)
                @log.display "Removed DNS record '#{oneid}'."
              else
                @log.error "Cannot find DNS record '#{oneid}'."
              end
            }
          }
        }
      end
    end
  end
end

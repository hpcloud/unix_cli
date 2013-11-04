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

      map %w(addresses:rm addresses:delete addresses:release addresses:del) => 'addresses:remove'

      desc "addresses:remove ip_or_id [ip_or_id ...]", "Remove or release a public IP address."
      long_desc <<-DESC
  Remove or release a previously allocated public IP address. Any server instances that were associated to this address are disassociated. You may specify one ore more address IPs or IDs on the command line.  Optionally, you can specify an availability zone.

Examples:
  hpcloud addresses:remove 111.111.111.111 # Remove IP address '111.111.111.111'
  hpcloud addresses:remove a5bd6680 c80dfe05 # Remove addresses with the IDs 'a5bd6680' and 'c80dfe05'

Aliases: addresses:rm, addresses:delete, addresses:release, addresses:del
      DESC
      CLI.add_common_options
      define_method "addresses:remove" do |ip, *ips|
        cli_command(options) {
          addresses = FloatingIps.new
          ips = [ip] + ips
          ips.each { |ip_or_id|
            address = addresses.get(ip_or_id)
            if address.is_valid? == false
              @log.error address.cstatus
            else
              address.disassociate
              address.destroy
              @log.display "Removed address '#{ip_or_id}'."
            end
          }
        }
      end
    end
  end
end

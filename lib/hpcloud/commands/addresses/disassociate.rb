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

      map 'addresses:detach' => 'addresses:disassociate'

      desc "addresses:disassociate ip_or_id [ip_or_id ...]", "Disassociate any port associated to the public IP address."
      long_desc <<-DESC
  Disassociate any port associated to the public IP address. The public IP address is not removed or released to the pool. Optionally, you can specify an availability zone.

Examples:
  hpcloud addresses:disassociate 111.111.111.111 127.0.0.1 # Disassociate IP addresses `111.111.111.111` and `127.0.0.1` from their ports
  hpcloud addresses:disassociate f01b27f3 # Disassociate the address with the ID  '9709'
      DESC
      CLI.add_common_options
      define_method "addresses:disassociate" do |ip_or_id, *ip_or_ids|
        cli_command(options) {
          addresses = FloatingIps.new
          ip_or_ids = [ip_or_id] + ip_or_ids
          ip_or_ids.each { |ip_or_id|
            address = addresses.get(ip_or_id)
            if address.is_valid? == false
              @log.error address.cstatus
            else
              if address.port.nil?
                @log.display "You don't have any port associated with address '#{ip_or_id}'."
              else
                address.port = nil
                @log.display "Disassociated address '#{ip_or_id}' from any port."
              end
            end
          }
        }
      end
    end
  end
end

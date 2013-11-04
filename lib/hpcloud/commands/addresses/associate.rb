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

      map 'addresses:attach' => 'addresses:associate'

      desc "addresses:associate <ip_or_id> <port_name_or_id>", "Associate a public IP address to a port."
      long_desc <<-DESC
  Associate an existing and unassigned public IP address, to the specified port.  Optionally, you can specify an availability.

Examples:
  hpcloud addresses:associate 111.111.111.111 myport  # Associate the address `111.111.111.111` to port `myport`
      DESC
      CLI.add_common_options
      define_method "addresses:associate" do |ip_or_id, port_name_or_id|
        cli_command(options) {
          port = Ports.new.get(port_name_or_id)
          if port.is_valid? == false
            @log.fatal port.cstatus
          end

          address = FloatingIps.new.get(ip_or_id)
          if address.is_valid? == false
            @log.fatal address.cstatus
          end

          if address.port.nil? == false
            if address.port == port.id
              @log.display "The IP address '#{ip_or_id}' is already associated with '#{port_name_or_id}'."
            else
              @log.fatal "The IP address '#{ip_or_id}' is in use by another port '#{address.port}'.", :conflicted
            end
          else
            address.port = port.id
            address.associate
            @log.display "Associated address '#{ip_or_id}' to port '#{port_name_or_id}'."
          end
        }
      end
    end
  end
end

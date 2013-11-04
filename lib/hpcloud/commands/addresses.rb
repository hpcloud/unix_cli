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

require 'hpcloud/commands/addresses/add'
require 'hpcloud/commands/addresses/remove'
require 'hpcloud/commands/addresses/associate'
require 'hpcloud/commands/addresses/disassociate'

module HP
  module Cloud
    class CLI < Thor

      map 'addresses:list' => 'addresses'

      desc "addresses [ip_or_id ...]", "Display list of available addresses."
      long_desc <<-DESC
  List the available addresses for your account. You may filter the addresses listed by specifying one or more IPs or IDs on the command line.  Optionally, you can specify an availability zone.

Examples:
  hpcloud addresses                            # List addresses
  hpcloud addresses 127.0.0.2                  # List address information for IP address 127.0.0.2
  hpcloud addresses -z az-2.region-a.geo-1     # List addresses for availability zone `az-2.region-a.geo-1`

Aliases: addresses:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      def addresses(*arguments)
        cli_command(options) {
          addresses = FloatingIps.new
          if addresses.empty?
            @log.display "You currently have no public IP addresses, use `#{selfname} addresses:add` to create one."
          else
            ray = addresses.get_array(arguments)
            if ray.empty?
              @log.display "There are no IP addresses that match the provided arguments"
            else
              Tableizer.new(options, FloatingIpHelper.get_keys(), ray).print
            end
          end
        }
      end
    end
  end
end

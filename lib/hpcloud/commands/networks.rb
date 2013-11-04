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

require 'hpcloud/commands/networks/add.rb'
require 'hpcloud/commands/networks/remove.rb'
require 'hpcloud/commands/networks/update.rb'
require 'hpcloud/networks'

module HP
  module Cloud
    class CLI < Thor

      map 'networks:list' => 'networks'
    
      desc 'networks [name_or_id ...]', "List the available networks."
      long_desc <<-DESC
  Lists all the networks that are associated with the account. The list begins with identifier and contains name, status, shared, admin state, and subnets.  Optionally, you can filter the list by specifying name or ID.

Examples:
  hpcloud networks       # List all networks
  hpcloud networks 12857174     # List the details for networks with id `12857174`
  hpcloud networks testo # List the details for networks named `testo`

Aliases: networks:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      def networks(*arguments)
        cli_command(options) {
          networks = Networks.new
          if networks.empty?
            @log.display "You currently have no networks, use `#{selfname} networks:add <name>` to create one."
          else
            ray = networks.get_array(arguments)
            if ray.empty?
              @log.display "There are no networks that match the provided arguments"
            else
              Tableizer.new(options, NetworkHelper.get_keys(), ray).print
            end
          end
        }
      end
    end
  end
end

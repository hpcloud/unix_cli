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

require 'hpcloud/commands/routers/add.rb'
require 'hpcloud/commands/routers/remove.rb'
require 'hpcloud/commands/routers/update.rb'
require 'hpcloud/commands/routers/interface/add.rb'
require 'hpcloud/commands/routers/interface/remove.rb'
require 'hpcloud/routers'

module HP
  module Cloud
    class CLI < Thor

      map 'routers:list' => 'routers'
    
      desc 'routers [name_or_id ...]', "List the available routers."
      long_desc <<-DESC
  Lists all the routers that are associated with the account. The list begins with identifier and contains name, status, administrative state, and gateways.  Optionally, you can filter the list by specifying name or ID.

Examples:
  hpcloud routers       # List all routers
  hpcloud routers c14411d7     # List the details for routers with id `c14411d7`
  hpcloud routers testo # List the details for routers named `testo`

Aliases: routers:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      def routers(*arguments)
        columns = [ "id", "name", "admin_state_up", "status", "external_gateway_info" ]
        cli_command(options) {
          routers = Routers.new
          if routers.empty?
            @log.display "You currently have no routers, use `#{selfname} routers:add <name>` to create one."
          else
            ray = routers.get_array(arguments)
            if ray.empty?
              @log.display "There are no routers that match the provided arguments"
            else
              Tableizer.new(options, columns, ray).print
            end
          end
        }
      end
    end
  end
end

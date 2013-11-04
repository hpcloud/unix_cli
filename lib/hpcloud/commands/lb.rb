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

require 'hpcloud/commands/lb/add.rb'
require 'hpcloud/commands/lb/algorithms.rb'
require 'hpcloud/commands/lb/limits.rb'
require 'hpcloud/commands/lb/nodes.rb'
require 'hpcloud/commands/lb/nodes/add.rb'
require 'hpcloud/commands/lb/nodes/remove.rb'
require 'hpcloud/commands/lb/nodes/update.rb'
require 'hpcloud/commands/lb/protocols.rb'
require 'hpcloud/commands/lb/remove.rb'
require 'hpcloud/commands/lb/update.rb'
require 'hpcloud/commands/lb/versions.rb'
require 'hpcloud/commands/lb/virtualips.rb'
require 'hpcloud/lbs'

module HP
  module Cloud
    class CLI < Thor

      map 'lb:list' => 'lb'
    
      desc 'lb [name_or_id ...]', "List the available load balancers."
      long_desc <<-DESC
  Lists all the load balancers that are associated with the account. The list begins with identifier and contains name, algorithm, protocol, port and status.  Optionally, you can filter the list by specifying names or IDs.

Examples:
  hpcloud lb          # List all load balancers
  hpcloud lb 1        # List the details for load balancers `1`
  hpcloud lb testvol  # List the details for load balancers `testvol`

Aliases: lb:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      def lb(*arguments)
        columns = [ "id", "name", "algorithm", "protocol", "port", "status" ]
        cli_command(options) {
          lb = Lbs.new
          if lb.empty?
            @log.display "You currently have no load balancers, use `#{selfname} lb:add <name>` to create one."
          else
            ray = lb.get_array(arguments)
            if ray.empty?
              @log.display "There are no load balancers that match the provided arguments"
            else
              Tableizer.new(options, columns, ray).print
            end
          end
        }
      end
    end
  end
end

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

require 'hpcloud/commands/snapshots/add'
require 'hpcloud/commands/snapshots/remove'
require 'hpcloud/snapshots'

module HP
  module Cloud
    class CLI < Thor

      map 'snapshots:list' => 'snapshots'
    
      desc 'snapshots [name_or_id ...]', "List block devices available."
      long_desc <<-DESC
  Lists all block snapshots associated with the account on the server. The list starts with identifier and contains name, size, type, create date, status, description and servers to which it is attached.  Optionally, you can filter the list by name or ID.

Examples:
  hpcloud snapshots           # List all snapshots
  hpcloud snapshots b8e90a48  # List the detail information for snapshot `b8e90a48`
  hpcloud snapshots testsnap  # List the detail information about snapshot `testsnap`

Aliases: snapshots:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      def snapshots(*arguments)
        cli_command(options) {
          snapshots = Snapshots.new
          if snapshots.empty?
            @log.display "You currently have no block snapshot devices, use `#{selfname} snapshots:add <name>` to create one."
          else
            ray = snapshots.get_array(arguments)
            if ray.empty?
              @log.display "There are no snapshots that match the provided arguments"
            else
              Tableizer.new(options, SnapshotHelper.get_keys(), ray).print
            end
          end
        }
      end
    end
  end
end

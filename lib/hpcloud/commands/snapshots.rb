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
  hpcloud snapshots           # List all snapshots:
  hpcloud snapshots 1         # List the detail information for snapshot `1`:
  hpcloud snapshots testsnap  # List the detail information about snapshot `testsnap`:

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

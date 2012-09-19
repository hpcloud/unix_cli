require 'hpcloud/commands/snapshots/add'
require 'hpcloud/snapshots'

module HP
  module Cloud
    class CLI < Thor

      map 'snapshots:list' => 'snapshots'
    
      desc 'snapshots [id|displayName] ...', "list block devices available optionally filtered by identifer or display name"
      long_desc <<-DESC
  The snapshots list command will list all the block snapshots that are associated with the account on the server. The list starts with identifier and contains name, size, type, create date, status, description and servers on which it is attached.  Optionally, the list may be filtered by specifying identifiers or names on the command line.

Examples:
  hpcloud snapshots           # List out all the snapshots
  hpcloud snapshots 1         # List details about snapshot 1
  hpcloud snapshots testsnap  # List details about snapshots named testsnap

Aliases: snapshots:list
      DESC
      CLI.add_common_options
      def snapshots(*arguments)
        cli_command(options) {
          snapshots = Snapshots.new
          if snapshots.empty?
            display "You currently have no block snapshot devices, use `#{selfname} snapshots:add <name>` to create one."
          else
            hsh = snapshots.get_hash(arguments)
            if hsh.empty?
              display "There are no snapshots that match the provided arguments"
            else
              tablelize(hsh, SnapshotHelper.get_keys())
            end
          end
        }
      end
    end
  end
end

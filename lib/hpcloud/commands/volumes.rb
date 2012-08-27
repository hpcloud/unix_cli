require 'hpcloud/commands/volumes/add'
require 'hpcloud/commands/volumes/attach'
require 'hpcloud/commands/volumes/detach'
require 'hpcloud/commands/volumes/remove'
require 'hpcloud/commands/volumes/server'
require 'hpcloud/volumes'

module HP
  module Cloud
    class CLI < Thor

      map 'volumes:list' => 'volumes'
    
      desc 'volumes [id|displayName] ...', "list block devices available optionally filtered by identifer or display name"
      long_desc <<-DESC
  The volumes list command will list all the block volumes that are associated with the account on the server. The list starts with identifier and contains name, size, type, create date, status, description and servers on which it is attached.  Optionally, the list may be filtered by specifying identifiers or names on the command line.

Examples:
  hpcloud volumes          # List out all the volumes
  hpcloud volumes 1        # List details about volume 1
  hpcloud volumes testvol  # List details about volumes named testvol

Aliases: volumes:list
      DESC
      CLI.add_common_options()
      def volumes(*arguments)
        cli_command(options) {
          volumes = Volumes.new
          if volumes.empty?
            display "You currently have no block volume devices, use `#{selfname} volumes:add <name>` to create one."
          else
            hsh = volumes.get_hash(arguments)
            if hsh.empty?
              display "There are no volumes that match the provided arguments"
            else
              tablelize(hsh, VolumeHelper.get_keys())
            end
          end
        }
      end
    end
  end
end

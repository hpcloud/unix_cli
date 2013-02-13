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
    
      desc 'volumes [name_or_id ...]', "List the available block devices."
      long_desc <<-DESC
  Lists all the block volumes that are associated with the account on the server. The list begins with identifier and contains name, size, type, create date, status, description and servers on which it is attached.  Optionally, you can filter the list by specifying name or ID.

Examples:
  hpcloud volumes          # List all volumes:
  hpcloud volumes 1        # List the details for volume `1`:
  hpcloud volumes testvol  # List the details for volume `testvol`:

Aliases: volumes:list
      DESC
      method_option :bootable, :type => :boolean, :aliases => '-b',
                    :default => false, :desc => 'List only the bootable volumes.'
      CLI.add_report_options
      CLI.add_common_options
      def volumes(*arguments)
        cli_command(options) {
          volumes = Volumes.new(options[:bootable])
          if volumes.empty?
            bootable = ""
            if options[:bootable]
              bootable = "bootable "
            end
            @log.display "You currently have no #{bootable}block volume devices, use `#{selfname} volumes:add <name>` to create one."
          else
            ray = volumes.get_array(arguments)
            if ray.empty?
              @log.display "There are no volumes that match the provided arguments"
            else
              Tableizer.new(options, VolumeHelper.get_keys(), ray).print
            end
          end
        }
      end
    end
  end
end

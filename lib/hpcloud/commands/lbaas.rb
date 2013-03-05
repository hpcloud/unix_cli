require 'hpcloud/commands/lbaas/add.rb'
require 'hpcloud/commands/lbaas/remove.rb'
require 'hpcloud/lbaass'

module HP
  module Cloud
    class CLI < Thor

      map 'lbaas:list' => 'lbaas'
    
      desc 'lbaas [name_or_id ...]', "List the available block devices."
      long_desc <<-DESC
  Lists all the load balancers that are associated with the account. The list begins with identifier and contains name, size, type, create date, status, description and servers on which it is attached.  Optionally, you can filter the list by specifying name or ID.

Examples:
  hpcloud lbaas          # List all lbaas:
  hpcloud lbaas 1        # List the details for lbaas `1`:
  hpcloud lbaas testvol  # List the details for lbaas `testvol`:

Aliases: lbaas:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      def lbaas(*arguments)
        cli_command(options) {
          lbaass = Lbaass.new
          if lbaass.empty?
            @log.display "You currently have no load balancers, use `#{selfname} lbaas:add <name>` to create one."
          else
            ray = lbaass.get_array(arguments)
            if ray.empty?
              @log.display "There are no load balancers that match the provided arguments"
            else
              Tableizer.new(options, LbaasHelper.get_keys(), ray).print
            end
          end
        }
      end
    end
  end
end

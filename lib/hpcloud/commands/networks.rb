require 'hpcloud/commands/networks/add.rb'
require 'hpcloud/commands/networks/remove.rb'
require 'hpcloud/networks'

module HP
  module Cloud
    class CLI < Thor

      map 'networks:list' => 'networks'
    
      desc 'networks [name_or_id ...]', "List the available block devices."
      long_desc <<-DESC
  Lists all the networks that are associated with the account. The list begins with identifier and contains name, status, shared, admin state, and subnets.  Optionally, you can filter the list by specifying name or ID.

Examples:
  hpcloud networks       # List all networks:
  hpcloud networks 1     # List the details for networks with id `1`:
  hpcloud networks testo # List the details for networks named `testo`:

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

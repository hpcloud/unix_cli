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
  hpcloud routers       # List all routers:
  hpcloud routers 1     # List the details for routers with id `1`:
  hpcloud routers testo # List the details for routers named `testo`:

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

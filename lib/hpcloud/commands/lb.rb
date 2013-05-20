require 'hpcloud/commands/lb/add.rb'
require 'hpcloud/commands/lb/algorithms.rb'
require 'hpcloud/commands/lb/limits.rb'
require 'hpcloud/commands/lb/nodes.rb'
require 'hpcloud/commands/lb/nodes/add.rb'
require 'hpcloud/commands/lb/nodes/remove.rb'
require 'hpcloud/commands/lb/protocols.rb'
require 'hpcloud/commands/lb/remove.rb'
require 'hpcloud/lbs'

module HP
  module Cloud
    class CLI < Thor

      map 'lb:list' => 'lb'
    
      desc 'lb [name_or_id ...]', "List the available load balancers."
      long_desc <<-DESC
  Lists all the load balancers that are associated with the account. The list begins with identifier and contains name, size, type, create date, status, description and servers on which it is attached.  Optionally, you can filter the list by specifying name or ID.

Examples:
  hpcloud lb          # List all load balancers:
  hpcloud lb 1        # List the details for load balancers `1`:
  hpcloud lb testvol  # List the details for load balancers `testvol`:

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

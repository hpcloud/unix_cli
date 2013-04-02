#require 'hpcloud/commands/subnets/add.rb'
#require 'hpcloud/commands/subnets/remove.rb'
#require 'hpcloud/commands/subnets/update.rb'
require 'hpcloud/subnets'

module HP
  module Cloud
    class CLI < Thor

      map 'subnets:list' => 'subnets'
    
      desc 'subnets [name_or_id ...]', "List the available subnets."
      long_desc <<-DESC
  Lists all the subnets that are associated with the account. The list begins with identifier and contains name, status, shared, admin state, and subnets.  Optionally, you can filter the list by specifying name or ID.

Examples:
  hpcloud subnets       # List all subnets:
  hpcloud subnets 1     # List the details for subnets with id `1`:
  hpcloud subnets testo # List the details for subnets named `testo`:

Aliases: subnets:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      def subnets(*arguments)
        cli_command(options) {
          subnets = Subnets.new
          if subnets.empty?
            @log.display "You currently have no subnets, use `#{selfname} subnets:add <name>` to create one."
          else
            ray = subnets.get_array(arguments)
            if ray.empty?
              @log.display "There are no subnets that match the provided arguments"
            else
              Tableizer.new(options, SubnetHelper.get_keys(), ray).print
            end
          end
        }
      end
    end
  end
end

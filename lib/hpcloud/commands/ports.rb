require 'hpcloud/commands/ports/add.rb'
require 'hpcloud/commands/ports/remove.rb'
require 'hpcloud/commands/ports/update.rb'
require 'hpcloud/ports'

module HP
  module Cloud
    class CLI < Thor

      map 'ports:list' => 'ports'
    
      desc 'ports [name_or_id ...]', "List the available ports."
      long_desc <<-DESC
  Lists all the ports that are associated with the account. The list begins with identifier and contains name, network identifier, fixed IPs, MAC address, status, admin state, device identifier, and device owner.  Optionally, you can filter the list by specifying name or ID.

Examples:
  hpcloud ports       # List all ports:
  hpcloud ports 1     # List the details for ports with id `1`:
  hpcloud ports testo # List the details for ports named `testo`:

Aliases: ports:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      def ports(*arguments)
        cli_command(options) {
          ports = Ports.new
          if ports.empty?
            @log.display "You currently have no ports, use `#{selfname} ports:add <name>` to create one."
          else
            ray = ports.get_array(arguments)
            if ray.empty?
              @log.display "There are no ports that match the provided arguments"
            else
              Tableizer.new(options, PortHelper.get_keys(), ray).print
            end
          end
        }
      end
    end
  end
end

require 'hpcloud/commands/dns/add.rb'
require 'hpcloud/dnss'

module HP
  module Cloud
    class CLI < Thor

      map 'dns:list' => 'dns'
    
      desc 'dns [name_or_id ...]', "List the available block devices."
      long_desc <<-DESC
  Lists all the load balancers that are associated with the account. The list begins with identifier and contains name, size, type, create date, status, description and servers on which it is attached.  Optionally, you can filter the list by specifying name or ID.

Examples:
  hpcloud dns          # List all dns:
  hpcloud dns 1        # List the details for dns `1`:
  hpcloud dns testvol  # List the details for dns `testvol`:

Aliases: dns:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      def dns(*arguments)
        cli_command(options) {
          dnss = Dnss.new
          if dnss.empty?
            @log.display "You currently have no load balancers, use `#{selfname} dns:add <name>` to create one."
          else
            ray = dnss.get_array(arguments)
            if ray.empty?
              @log.display "There are no load balancers that match the provided arguments"
            else
              Tableizer.new(options, DnsHelper.get_keys(), ray).print
            end
          end
        }
      end
    end
  end
end

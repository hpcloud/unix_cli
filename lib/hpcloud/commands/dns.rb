require 'hpcloud/commands/dns/add'
require 'hpcloud/commands/dns/remove'
require 'hpcloud/commands/dns/records'
require 'hpcloud/commands/dns/servers'
require 'hpcloud/commands/dns/update'
require 'hpcloud/dnss'

module HP
  module Cloud
    class CLI < Thor

      map 'dns:list' => 'dns'
    
      desc 'dns [name_or_id ...]', "List the DNS domains."
      long_desc <<-DESC
  Lists all the DNS domains that are associated with the account. The list begins with identifier and contains name, TTL, serial number, email and time created.  Optionally, you can filter the list by specifying name or ID.

Examples:
  hpcloud dns            # List all dns domains:
  hpcloud dns 421e8cbf   # List dns domain with id `421e8cbf`:
  hpcloud dns test.com.  # List dns domain `test.com.`:

Aliases: dns:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      def dns(*arguments)
        cli_command(options) {
          dnss = Dnss.new
          if dnss.empty?
            @log.display "You currently have no DNS domains, use `#{selfname} dns:add <name>` to create one."
          else
            ray = dnss.get_array(arguments)
            if ray.empty?
              @log.display "There are no DNS domains that match the provided arguments"
            else
              Tableizer.new(options, DnsHelper.get_keys(), ray).print
            end
          end
        }
      end
    end
  end
end

require 'hpcloud/commands/dns/add.rb'
require 'hpcloud/commands/dns/remove.rb'
require 'hpcloud/commands/dns/update.rb'
require 'hpcloud/dnss'

module HP
  module Cloud
    class CLI < Thor

      desc 'dns:servers <name_or_id>', "List the servers associated with the DNS domain."
      long_desc <<-DESC
  Lists servers associated with the DNS domain specified by name or ID.

Examples:
  hpcloud dns:servers 421e8cbf   # List servers for the DNS domain with ID `421e8cbf`:
  hpcloud dns:servers test.com.  # List servers for the DNS domain `test.com.`:
      DESC
      CLI.add_report_options
      CLI.add_common_options
      define_method "dns:servers" do |name_or_id|
        cli_command(options) {
          dns = Dnss.new.get(name_or_id)
          if dns.is_valid? == false
            @log.fatal dns.cstatus
          end
          ray = dns.servers
          if ray.empty?
            @log.display "There are no servers associated with this DNS domain"
          else
            Tableizer.new(options, dns.server_keys, ray).print
          end
        }
      end
    end
  end
end

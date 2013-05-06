require 'hpcloud/commands/dns/records/add.rb'
require 'hpcloud/commands/dns/records/remove.rb'
require 'hpcloud/commands/dns/records/update.rb'
require 'hpcloud/dnss'

module HP
  module Cloud
    class CLI < Thor

      desc 'dns:records <name_or_id>', "List the records associated with the DNS domain."
      long_desc <<-DESC
  Lists records associated with the DNS domain specified by name or ID.

Examples:
  hpcloud dns:records 421e8cbf   # List records for DNS domain with ID `421e8cbf`:
  hpcloud dns:records test.com.  # List records for DNS domain `test.com`:
      DESC
      CLI.add_report_options
      CLI.add_common_options
      define_method "dns:records" do |name_or_id|
        cli_command(options) {
          dns = Dnss.new.get(name_or_id)
          if dns.is_valid? == false
            @log.fatal dns.cstatus
          end
          ray = dns.records
          if ray.empty?
            @log.display "There are no records associated with this DNS domain"
          else
            Tableizer.new(options, dns.record_keys, ray).print
          end
        }
      end
    end
  end
end

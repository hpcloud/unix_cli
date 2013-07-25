module HP
  module Cloud
    class CLI < Thor

      map %w(dns:rm dns:delete dns:del) => 'dns:remove'

      desc "dns:remove name_or_id [name_or_id ...]", "Remove DNS domains (specified by name or ID)."
      long_desc <<-DESC
  Remove DNS domains by specifying their names or ID. You may specify more than one DNS name or ID on a command line.  Optionally, you can specify an availability zone.

Examples:
  hpcloud dns:remove mydomain.com. yourdomain.com. # Delete the DNS domains `mydomain.com.` and `yourdomain.com.`
  hpcloud dns:remove f3f3a427                      # Delete the DNS domain with ID f3f3a427

Aliases: dns:rm, dns:delete, dns:del
      DESC
      CLI.add_common_options
      define_method "dns:remove" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          dnss = Dnss.new.get(name_or_ids, false)
          dnss.each { |dns|
            sub_command("removing dns") {
              if dns.is_valid?
                dns.destroy
                @log.display "Removed dns '#{dns.name}'."
              else
                @log.error dns.cstatus
              end
            }
          }
        }
      end
    end
  end
end

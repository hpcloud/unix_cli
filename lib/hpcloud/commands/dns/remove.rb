module HP
  module Cloud
    class CLI < Thor

      map %w(dns:rm dns:delete dns:del) => 'dns:remove'

      desc "dns:remove name_or_id [name_or_id ...]", "Remove DNS domains (specified by name or ID)."
      long_desc <<-DESC
  Remove DNS domains by specifying their names or ID. You may specify more than one DNS name or ID on a command line.  Optionally, you can specify an availability zone.

Examples:
  hpcloud dns:remove tome treatise   # Delete the DNS domains `tome` and `treatise`:
  hpcloud dns:remove 998             # Delete the DNS domain with ID 998:
  hpcloud dns:remove my-dns -z az-2.region-a.geo-1  # Delete the DNS domain `my-dns` for availability zone `az-2.region-a.geo-1`:

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

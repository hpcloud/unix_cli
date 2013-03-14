module HP
  module Cloud
    class CLI < Thor

      map %w(dns:rm dns:delete dns:del) => 'dns:remove'

      desc "dns:remove name_or_id [name_or_id ...]", "Remove a dns settings (specified by name or ID)."
      long_desc <<-DESC
  Remove dns settings by specifying their names or ID. You may specify more than one dns name or ID on a command line.  Optionally, you can specify an availability zone.

Examples:
  hpcloud dns:remove tome treatise   # Delete the dns 'tome' and 'treatise':
  hpcloud dns:remove 998             # Delete the dns with ID 998:
  hpcloud dns:remove my-dns -z az-2.region-a.geo-1  # Delete the dns `my-dns` for availability zone `az-2.region-a.geo-1`:

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

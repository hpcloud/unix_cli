module HP
  module Cloud
    class CLI < Thor

      map %w(lbaas:rm lbaas:delete lbaas:del) => 'lbaas:remove'

      desc "lbaas:remove name_or_id [name_or_id ...]", "Remove a load balancers (specified by name or ID)."
      long_desc <<-DESC
  Remove load balancers by specifying their names or ID. You may specify more than one load balancer name or ID on a command line.  Optionally, you can specify an availability zone.

Examples:
  hpcloud lbaas:remove tome treatise   # Delete the lbaas 'tome' and 'treatise':
  hpcloud lbaas:remove 998             # Delete the lbaas with ID 998:
  hpcloud lbaas:remove my-lbaas -z az-2.region-a.geo-1  # Delete the lbaas `my-lbaas` for availability zone `az-2.region-a.geo-1`:

Aliases: lbaas:rm, lbaas:delete, lbaas:del
      DESC
      CLI.add_common_options
      define_method "lbaas:remove" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          lbaass = Lbaass.new.get(name_or_ids, false)
          lbaass.each { |lbaas|
            sub_command("removing lbaas") {
              if lbaas.is_valid?
                lbaas.destroy
                @log.display "Removed lbaas '#{lbaas.name}'."
              else
                @log.error lbaas.cstatus
              end
            }
          }
        }
      end
    end
  end
end

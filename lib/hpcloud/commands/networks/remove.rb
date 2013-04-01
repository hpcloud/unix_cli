module HP
  module Cloud
    class CLI < Thor

      map %w(networks:rm networks:delete networks:del) => 'networks:remove'

      desc "networks:remove name_or_id [name_or_id ...]", "Remove a network settings (specified by name or ID)."
      long_desc <<-DESC
  Remove network settings by specifying their names or ID. You may specify more than one network name or ID on a command line.  Optionally, you can specify an availability zone.

Examples:
  hpcloud networks:remove tome treatise   # Delete the network 'tome' and 'treatise':
  hpcloud networks:remove 998             # Delete the network with ID 998:
  hpcloud networks:remove my-network -z az-2.region-a.geo-1  # Delete the network `my-network` for availability zone `az-2.region-a.geo-1`:

Aliases: networks:rm, networks:delete, networks:del
      DESC
      CLI.add_common_options
      define_method "networks:remove" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          networks = Networks.new.get(name_or_ids, false)
          networks.each { |network|
            sub_command("removing network") {
              if network.is_valid?
                network.destroy
                @log.display "Removed network '#{network.name}'."
              else
                @log.error network.cstatus
              end
            }
          }
        }
      end
    end
  end
end

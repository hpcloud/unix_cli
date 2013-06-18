module HP
  module Cloud
    class CLI < Thor

      map %w(networks:rm networks:delete networks:del) => 'networks:remove'

      desc "networks:remove name_or_id [name_or_id ...]", "Remove a network (specified by name or ID)."
      long_desc <<-DESC
  Remove network by specifying their names or ID. You may specify more than one network name or ID on a command line.

Examples:
  hpcloud networks:remove arpa darpa   # Delete the network 'arpa' and 'darpa'
  hpcloud networks:remove 998          # Delete the network with ID 998
  hpcloud networks:remove netty -z region-a.geo-1  # Delete the network `netty` for availability zone `region-a.geo-1`

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

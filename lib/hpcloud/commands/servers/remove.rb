module HP
  module Cloud
    class CLI < Thor

      map %w(servers:rm servers:delete servers:del) => 'servers:remove'

      desc "servers:remove name_or_id [name_or_id ...]", "Remove a server or servers (specified by name or ID)."
      long_desc <<-DESC
  Remove existing servers by specifying their name or ID. Optionally, you can specify an availability zone.

Examples:
  hpcloud servers:remove my-server          # Delete 'my-server':
  hpcloud servers:remove DeepThought Blaine # Delete the servers 'DeepThought' and 'Blaine':
  hpcloud servers:remove 369765             # Delete the server with the ID 369765
  hpcloud servers:remove my-server -z az-2.region-a.geo-1  # Delete server `my-server` for availability zone `az-2.region-a.geo-1`:

Aliases: servers:rm, servers:delete, servers:del
      DESC
      CLI.add_common_options
      define_method "servers:remove" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          servers = Servers.new.get(name_or_ids, false)
          servers.each { |server|
            sub_command("removing server") {
              if server.is_valid?
                server.destroy
                @log.display "Removed server '#{server.name}'."
              else
                @log.error server.cstatus
              end
            }
          }
        }
      end
    end
  end
end

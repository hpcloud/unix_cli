module HP
  module Cloud
    class CLI < Thor

      map %w(servers:rm servers:delete servers:del) => 'servers:remove'

      desc "servers:remove name_or_id [name_or_id ...]", "remove servers by name or id"
      long_desc <<-DESC
  Remove existing servers by specifying their name or ids. Optionally, an availability zone can be passed.

Examples:
  hpcloud servers:remove my-server          # delete 'my-server'
  hpcloud servers:remove DeepThought Blaine # delete 'DeepThought' and 'Blaine'
  hpcloud servers:remove 369765             # delete server with id 369765
  hpcloud servers:remove my-server -z az-2.region-a.geo-1  # Optionally specify an availability zone

Aliases: servers:rm, servers:delete, servers:del
      DESC
      CLI.add_common_options
      define_method "servers:remove" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          servers = Servers.new.get(name_or_ids, false)
          servers.each { |server|
            begin
              if server.is_valid?
                server.destroy
                display "Removed server '#{server.name}'."
              else
                error_message(server.error_string, server.error_code)
              end
            rescue Exception => e
              error_message("Error removing server: " + e.to_s, :general_error)
            end
          }
        }
      end
    end
  end
end

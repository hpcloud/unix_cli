module HP
  module Cloud
    class CLI < Thor

      map %w(servers:rm servers:delete servers:del) => 'servers:remove'

      desc "servers:remove <name>", "remove a server by name"
      long_desc <<-DESC
  Remove an existing server by specifying its name. Optionally, an availability zone can be passed.

Examples:
  hpcloud servers:remove my-server          # delete 'my-server'
  hpcloud servers:remove my-server -z az-2.region-a.geo-1  # Optionally specify an availability zone

Aliases: servers:rm, servers:delete, servers:del
      DESC
      GOPTS.each { |k,v| method_option(k, v) }
      define_method "servers:remove" do |name, *names|
        cli_command(options) {
          names = [name] + names
          servers = Servers.new.get(names, false)
          servers.each { |server|
            begin
              if server.is_valid?
                server.destroy
                display "Removed server '#{name}'."
              else
                error_message(server.error_string, server.error_code)
              end
            rescue Exception => e
              error_message("Error removing image: " + e.to_s, :general_error)
            end
          }
        }
      end

    end
  end
end

module HP
  module Cloud
    class CLI < Thor

      map %w(servers:delete servers:del) => 'servers:remove'

      desc "servers:remove <name>", "remove a server by name"
      long_desc <<-DESC
  Remove an existing server by specifying its name.

Examples:
  hpcloud servers:remove my-server          # delete 'my-server'

Aliases: servers:delete, servers:del
      DESC
      define_method "servers:remove" do |name|
        begin
          # setup connection for compute service
          compute_connection = connection(:compute)
          server = compute_connection.servers.select {|s| s.name == name}.first
        rescue Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
        if (server && server.name == name)
          begin
            # now delete the server
            server.destroy
            display "Removed server '#{name}'."
          rescue Excon::Errors::Conflict, Excon::Errors::Forbidden => error
            display_error_message(error)
          end
        else
          error "You don't have a server '#{name}'.", :not_found
        end
      end

    end
  end
end
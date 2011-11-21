module HP
  module Cloud
    class CLI < Thor

      map %w(servers:passwd) => 'servers:password'

      desc "servers:password <server_name> <password>", "change password for a server"
      long_desc <<-DESC
  Change the password for an existing server. The password should adhere to the existing
  security complexity naming rules set in place.

Examples:
  hpcloud servers:password my-server my-password         # change password for server 'my-server'

Aliases: servers:passwd
      DESC
      define_method "servers:password" do |name, password|
        begin
          # setup connection for compute service
          compute_connection = connection(:compute)
          server = compute_connection.servers.select {|s| s.name == name}.first
        rescue Excon::Errors::Forbidden, Excon::Errors::InternalServerError => error
          display_error_message(error, :permission_denied)
        end
        if server
          begin
            server.change_password(password)
            display "Password changed for server '#{name}'."
          rescue Excon::Errors::Conflict, Excon::Errors::Forbidden, Excon::Errors::InternalServerError => error
            display_error_message(error)
          end
        else
          error "You don't have a server '#{name}'.", :not_found
        end
      end

    end
  end
end
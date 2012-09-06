module HP
  module Cloud
    class CLI < Thor

      map %w(servers:passwd) => 'servers:password'

      desc "servers:password <server_name> <password>", "change password for a server"
      long_desc <<-DESC
  Change the password for an existing server. The password should adhere to the existing
  security complexity naming rules set in place. Optionally, an availability zone can be passed.

Examples:
  hpcloud servers:password my-server my-password         # change password for server 'my-server'
  hpcloud servers:password my-server my-password -z az-2.region-a.geo-1   # Optionally specify an availability zone

Aliases: servers:passwd
      DESC
      CLI.add_common_options
      define_method "servers:password" do |name, password|
        cli_command(options) {
          compute_connection = connection(:compute, options)
          server = compute_connection.servers.select {|s| s.name == name}.first
          if server
              server.change_password(password)
              display "Password changed for server '#{name}'."
          else
            error "You don't have a server '#{name}'.", :not_found
          end
        }
      end

    end
  end
end

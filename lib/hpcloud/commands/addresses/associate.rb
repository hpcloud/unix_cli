module HP
  module Cloud
    class CLI < Thor

      desc "addresses:associate <public_ip> <server_name>", "associate a public IP address to a server instance"
      long_desc <<-DESC
  Associate an existing and unassigned public IP address, to the specified server instance.
  Optionally, an availability zone can be passed.

Examples:
  hpcloud addresses:associate 111.111.111.111 myserver
  hpcloud addresses:associate 111.111.111.111 myserver -z az-2.region-a.geo-1

Aliases: none
      DESC
      CLI.add_common_options
      define_method "addresses:associate" do |public_ip, server_name|
        cli_command(options) {
          compute_connection = connection(:compute, options)
          # get the address with the IP
          address = compute_connection.addresses.select {|a| a.ip == public_ip}.first
          if (address && address.ip == public_ip)
            # if the address is not assigned to any server
            if address.instance_id.nil?
              # get the server with the id
              server = compute_connection.servers.select {|s| s.name == server_name}.first
              if (server && server.name == server_name)
                # assign the address to the server
                address.server = server
                display "Associated address '#{public_ip}' to server '#{server_name}'."
              else
                error "You don't have a server '#{server_name}'.", :not_found
              end
            else
              error "The address with public IP '#{public_ip}', is in use by another server '#{server_name}'.", :not_found
            end
          else
            error "You don't have an address with public IP '#{public_ip}', use `hpcloud addresses:add` to create one.", :not_found
          end
        }
      end
    end
  end
end

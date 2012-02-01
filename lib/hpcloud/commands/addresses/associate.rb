module HP
  module Cloud
    class CLI < Thor

      desc "addresses:associate <public_ip> <server_name>", "associate a public IP address to a server instance"
      long_desc <<-DESC
  Associate an existing and unassigned public IP address, to the specified server instance.

Examples:
  hpcloud addresses:associate 111.111.111.111 myserver

Aliases: none
      DESC
      define_method "addresses:associate" do |public_ip, server_name|
        begin
          compute_connection = connection(:compute)
          # get the address with the IP
          address = compute_connection.addresses.select {|a| a.ip == public_ip}.first
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
        if (address && address.ip == public_ip)
          begin
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
          rescue Fog::Compute::HP::Error => error
            display_error_message(error, :general_error)
          rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
            display_error_message(error, :permission_denied)
          end
        else
          error "You don't have an address with public IP '#{public_ip}', use `hpcloud addresses:add` to create one.", :not_found
        end
      end

    end
  end
end
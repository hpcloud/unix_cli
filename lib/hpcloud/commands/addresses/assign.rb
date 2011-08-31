module HP
  module Cloud
    class CLI < Thor

      desc "addresses:assign <public_ip> <server_id", "assign a public IP address to a server."
      long_desc <<-DESC
  Assign an existing and unassigned public IP address, to the specified server instance.

Examples:
  hpcloud addresses:assign 127.0.0.1 i-00000001

Aliases: none
      DESC
      define_method "addresses:assign" do |public_ip, server_id|
        begin
          compute_connection = connection(:compute)
          # get the address with the IP
          address = compute_connection.addresses.select {|a| a.public_ip == public_ip}.first
        rescue Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
        if (address && address.public_ip == public_ip)
          begin
            # if the address is not assigned to any server
            if address.server_id.nil?
              # get the server with the id
              server = compute_connection.servers.select {|s| s.id == server_id}.first
              if (server && server.id == server_id)
                # assign the address to the server
                address.server = server
                display "Assigned address '#{public_ip}' to server with id '#{server.id}'."
              else
                error "You don't have a server with id '#{server_id}'.", :not_found
              end
            else
              error "The address with public IP '#{public_ip}', is in use by another server with id '#{server_id}'.", :not_found
            end
          rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
            display_error_message(error)
          end
        else
          error "You don't have an address with public IP '#{public_ip}', use `hpcloud addresses:add` to create one.", :not_found
        end
      end

    end
  end
end
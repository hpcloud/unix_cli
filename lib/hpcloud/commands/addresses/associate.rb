module HP
  module Cloud
    class CLI < Thor

      map 'addresses:attach' => 'addresses:associate'

      desc "addresses:associate <public_ip> <server_name_id>", "associate a public IP address to a server instance"
      long_desc <<-DESC
  Associate an existing and unassigned public IP address, to the specified server instance.
  Optionally, an availability zone can be passed.

Examples:
  hpcloud addresses:associate 111.111.111.111 myserver
  hpcloud addresses:associate 111.111.111.111 myserver -z az-2.region-a.geo-1

Aliases: none
      DESC
      CLI.add_common_options
      define_method "addresses:associate" do |ip_or_id, server_name_id|
        cli_command(options) {
          server = Servers.new.get(server_name_id)
          if server.is_valid? == false
            error server.error_string, server.error_code
          end

          address = Addresses.new.get(ip_or_id)
          if address.is_valid? == false
            error address.error_string, address.error_code
          end

          if address.instance_id.nil? == false
            if address.instance_id == server.id
              display "The IP address '#{ip_or_id}' is already associated with '#{server_name_id}'."
            else
              error "The IP address '#{ip_or_id}' is in use by another server '#{address.instance_id}'.", :conflicted
            end
          else
            address.fog.server = server
            display "Associated address '#{ip_or_id}' to server '#{server_name_id}'."
          end
        }
      end
    end
  end
end

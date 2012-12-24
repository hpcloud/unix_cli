module HP
  module Cloud
    class CLI < Thor

      map 'addresses:attach' => 'addresses:associate'

      desc "addresses:associate <ip_or_id> <server_name_or_id>", "Associate a public IP address to a server instance."
      long_desc <<-DESC
  Associate an existing and unassigned public IP address, to the specified server instance.  Optionally, you can specify an availability.

Examples:
  hpcloud addresses:associate 111.111.111.111 myserver  # Associate the address `111.111.111.111` to server `myserver`:
  hpcloud addresses:associate 111.111.111.111 myserver -z az-2.region-a.geo-1  # Associate the address `111.111.111.111` to server `myserver` in availability zone `az-2.region-a.geo-1`:
      DESC
      CLI.add_common_options
      define_method "addresses:associate" do |ip_or_id, server_name_or_id|
        cli_command(options) {
          server = Servers.new.get(server_name_or_id)
          if server.is_valid? == false
            @log.fatal server.cstatus
          end

          address = Addresses.new.get(ip_or_id)
          if address.is_valid? == false
            @log.fatal address.cstatus
          end

          if address.instance_id.nil? == false
            if address.instance_id == server.id
              @log.display "The IP address '#{ip_or_id}' is already associated with '#{server_name_or_id}'."
            else
              @log.fatal "The IP address '#{ip_or_id}' is in use by another server '#{address.instance_id}'.", :conflicted
            end
          else
            address.fog.server = server.fog
            @log.display "Associated address '#{ip_or_id}' to server '#{server_name_or_id}'."
          end
        }
      end
    end
  end
end

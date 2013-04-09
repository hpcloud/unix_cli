module HP
  module Cloud
    class CLI < Thor

      map 'addresses:attach' => 'addresses:associate'

      desc "addresses:associate <ip_or_id> <port_name_or_id>", "Associate a public IP address to a port."
      long_desc <<-DESC
  Associate an existing and unassigned public IP address, to the specified port.  Optionally, you can specify an availability.

Examples:
  hpcloud addresses:associate 111.111.111.111 myport  # Associate the address `111.111.111.111` to port `myport`:
  hpcloud addresses:associate 111.111.111.111 myport -z az-2.region-a.geo-1  # Associate the address `111.111.111.111` to port `myport` in availability zone `az-2.region-a.geo-1`:
      DESC
      CLI.add_common_options
      define_method "addresses:associate" do |ip_or_id, port_name_or_id|
        cli_command(options) {
          port = Servers.new.get(port_name_or_id)
          if port.is_valid? == false
            @log.fatal port.cstatus
          end

          address = FloatingIps.new.get(ip_or_id)
          if address.is_valid? == false
            @log.fatal address.cstatus
          end

          if address.port.nil? == false
            if address.port == port.id
              @log.display "The IP address '#{ip_or_id}' is already associated with '#{port_name_or_id}'."
            else
              @log.fatal "The IP address '#{ip_or_id}' is in use by another port '#{address.port}'.", :conflicted
            end
          else
            address.port = port.id
            address.associate
            @log.display "Associated address '#{ip_or_id}' to port '#{port_name_or_id}'."
          end
        }
      end
    end
  end
end

module HP
  module Cloud
    class CLI < Thor

      map %w(addresses:rm addresses:delete addresses:release addresses:del) => 'addresses:remove'

      desc "addresses:remove <public_ip>", "remove or release a public IP address"
      long_desc <<-DESC
  Remove or release a previously allocated public IP address. Any server instances that
  were associated to this address, will be disassociated. Optionally, an availability zone can be passed.

Examples:
  hpcloud addresses:remove 111.111.111.111
  hpcloud addresses:remove 111.111.111.111 -z az-2.region-a.geo-1   # Optionally specify an availability zone

Aliases: addresses:rm, addresses:delete, addresses:release, addresses:del
      DESC
      CLI.add_common_options
      define_method "addresses:remove" do |ip, *ips|
        cli_command(options) {
          compute_connection = connection(:compute, options)
          ips = [ip] + ips
          ips.each { |public_ip|
            address = compute_connection.addresses.select {|a| a.ip == public_ip}.first
            if (address && address.ip == public_ip)
              # Disassociate any server from this address
              address.server = nil unless address.instance_id.nil?
              # Release the address
              address.destroy
              display "Removed address '#{public_ip}'."
            else
              error_message "You don't have an address with public IP '#{public_ip}'.", :not_found
            end
          }
        }
      end
    end
  end
end

module HP
  module Cloud
    class CLI < Thor

      map %w(addresses:rm addresses:delete addresses:release addresses:del) => 'addresses:remove'

      desc "addresses:remove ip_or_id [ip_or_id ...]", "remove or release a public IP address"
      long_desc <<-DESC
  Remove or release a previously allocated public IP address. Any server instances that
  were associated to this address, will be disassociated. You may specify one ore more address IPs or ids on the command line.  Optionally, an availability zone can be passed.

Examples:
  hpcloud addresses:remove 111.111.111.111 # Remove IP address '111.111.111.111'
  hpcloud addresses:remove 1078 3709   # Remove addresses with ids '1078' and '3709'
  hpcloud addresses:remove 111.111.111.111 -z az-2.region-a.geo-1   # Optionally specify an availability zone

Aliases: addresses:rm, addresses:delete, addresses:release, addresses:del
      DESC
      CLI.add_common_options
      define_method "addresses:remove" do |ip, *ips|
        cli_command(options) {
          addresses = Addresses.new
          ips = [ip] + ips
          ips.each { |ip_or_id|
            address = addresses.get(ip_or_id)
            if address.is_valid? == false
              error_message address.error_string, address.error_code
            else
              address.fog.server = nil unless address.instance_id.nil?
              address.destroy
              display "Removed address '#{ip_or_id}'."
            end
          }
        }
      end
    end
  end
end

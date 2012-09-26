module HP
  module Cloud
    class CLI < Thor

      map 'addresses:detach' => 'addresses:disassociate'

      desc "addresses:disassociate <public_ip>", "disassociate any server instance associated to the public IP address"
      long_desc <<-DESC
  Disassociate any server instance associated to the public IP address. The public IP address is
  not removed or released to the pool. Optionally, an availability zone can be passed.

Examples:
  hpcloud addresses:disassociate 111.111.111.111
  hpcloud addresses:disassociate 111.111.111.111 -z az-2.region-a.geo-1

Aliases: none
      DESC
      CLI.add_common_options
      define_method "addresses:disassociate" do |ip_or_id, *ip_or_ids|
        cli_command(options) {
          addresses = Addresses.new
          ip_or_ids = [ip_or_id] + ip_or_ids
          ip_or_ids.each { |ip_or_id|
            address = addresses.get(ip_or_id)
            if address.is_valid? == false
              error_message address.error_string, address.error_code
            else
              if address.instance_id.nil?
                display "You don't have any server associated with address '#{ip_or_id}'."
              else
                address.fog.server = nil
                display "Disassociated address '#{ip_or_id}' from any server instance."
              end
            end
          }
        }
      end
    end
  end
end

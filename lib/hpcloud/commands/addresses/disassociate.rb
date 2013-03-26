module HP
  module Cloud
    class CLI < Thor

      map 'addresses:detach' => 'addresses:disassociate'

      desc "addresses:disassociate ip_or_id [ip_or_id ...]", "Disassociate any server instance associated to the public IP address."
      long_desc <<-DESC
  Disassociate any server instance associated to the public IP address. The public IP address is not removed or released to the pool. Optionally, you can specify an availability zone.

Examples:
  hpcloud addresses:disassociate 111.111.111.111 127.0.0.1 # Disassociate IP addresses `111.111.111.111` and `127.0.0.1` from the default server:
  hpcloud addresses:disassociate 9709 # Disassociate the address with the ID  '9709':
  hpcloud addresses:disassociate 111.111.111.111 -z az-2.region-a.geo-1  # Disassociate the address `111.111.111.111` for availability zone `az-2.region-a.geo-1`:
      DESC
      CLI.add_common_options
      define_method "addresses:disassociate" do |ip_or_id, *ip_or_ids|
        cli_command(options) {
          addresses = Addresses.new
          ip_or_ids = [ip_or_id] + ip_or_ids
          ip_or_ids.each { |ip_or_id|
            address = addresses.get(ip_or_id)
            if address.is_valid? == false
              @log.error address.cstatus
            else
              if address.instance_id.nil?
                @log.display "You don't have any server associated with address '#{ip_or_id}'."
              else
                address.fog.server = nil
                @log.display "Disassociated address '#{ip_or_id}' from any server instance."
              end
            end
          }
        }
      end
    end
  end
end

module HP
  module Cloud
    class CLI < Thor

      map 'addresses:detach' => 'addresses:disassociate'

      desc "addresses:disassociate ip_or_id [ip_or_id ...]", "Disassociate any port associated to the public IP address."
      long_desc <<-DESC
  Disassociate any port associated to the public IP address. The public IP address is not removed or released to the pool. Optionally, you can specify an availability zone.

Examples:
  hpcloud addresses:disassociate 111.111.111.111 127.0.0.1 # Disassociate IP addresses `111.111.111.111` and `127.0.0.1` from their ports
  hpcloud addresses:disassociate f01b27f3 # Disassociate the address with the ID  '9709'
      DESC
      CLI.add_common_options
      define_method "addresses:disassociate" do |ip_or_id, *ip_or_ids|
        cli_command(options) {
          addresses = FloatingIps.new
          ip_or_ids = [ip_or_id] + ip_or_ids
          ip_or_ids.each { |ip_or_id|
            address = addresses.get(ip_or_id)
            if address.is_valid? == false
              @log.error address.cstatus
            else
              if address.port.nil?
                @log.display "You don't have any port associated with address '#{ip_or_id}'."
              else
                address.port = nil
                @log.display "Disassociated address '#{ip_or_id}' from any port."
              end
            end
          }
        }
      end
    end
  end
end

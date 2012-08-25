module HP
  module Cloud
    class CLI < Thor

      desc "addresses:disassociate <public_ip>", "disassociate any server instance associated to the public IP address"
      long_desc <<-DESC
  Disassociate any server instance associated to the public IP address. The public IP address is
  not removed or released to the pool. Optionally, an availability zone can be passed.

Examples:
  hpcloud addresses:disassociate 111.111.111.111
  hpcloud addresses:disassociate 111.111.111.111 -z az-2.region-a.geo-1

Aliases: none
      DESC
      CLI.add_common_options()
      define_method "addresses:disassociate" do |public_ip|
        begin
          compute_connection = connection(:compute, options)
          # get the address with the IP
          address = compute_connection.addresses.select {|a| a.ip == public_ip}.first
          if (address && address.ip == public_ip)
            # if the address is not assigned to any server
            if address.instance_id.nil?
              display "You don't have any server associated with address '#{public_ip}'."
            else
              address.server = nil
              display "Disassociated address '#{public_ip}' from any server instance."
            end
          else
            error "You don't have an address with public IP '#{public_ip}', use `hpcloud addresses:add` to create one.", :not_found
          end
        rescue Fog::HP::Errors::ServiceError, Fog::Compute::HP::Error => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
      end

    end
  end
end

module HP
  module Cloud
    class CLI < Thor

      map %w(addresses:delete addresses:release addresses:del) => 'addresses:remove'

      desc "addresses:remove <public_ip>", "remove or release a public IP address"
      long_desc <<-DESC
  Remove or release a previously allocated public IP address.

Examples:
  hpcloud addresses:remove public_ip

Aliases: addresses:delete, addresses:release, addresses:del
      DESC
      define_method "addresses:remove" do |public_ip|
        begin
          compute_connection = connection(:compute)
          address = compute_connection.addresses.select {|a| a.public_ip == public_ip}.first
        rescue Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
        if (address && address.public_ip == public_ip)
          begin
            address.destroy
            display "Removed address '#{public_ip}'."
          rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
            display_error_message(error)
          end
        else
          error "You don't have an address with public IP '#{public_ip}'.", :not_found
        end
      end

    end
  end
end
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
      method_option :availability_zone,
                    :type => :string, :aliases => '-z',
                    :desc => 'Set the availability zone.'
      define_method "addresses:remove" do |public_ip|
        begin
          compute_connection = connection(:compute, options)
          address = compute_connection.addresses.select {|a| a.ip == public_ip}.first
          if (address && address.ip == public_ip)
            # Disassociate any server from this address
            address.server = nil unless address.instance_id.nil?
            # Release the address
            address.destroy
            display "Removed address '#{public_ip}'."
          else
            error "You don't have an address with public IP '#{public_ip}'.", :not_found
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
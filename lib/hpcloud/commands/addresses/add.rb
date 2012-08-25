module HP
  module Cloud
    class CLI < Thor

      map %w(addresses:allocate) => 'addresses:add'

      desc "addresses:add", "add or allocate a new public IP address"
      long_desc <<-DESC
  Add or allocate a new public IP address from the pool of available IP addresses.
  Optionally, an availability zone can be passed.

Examples:
  hpcloud addresses:add
  hpcloud addresses:add -z az-2.region-a.geo-1

Aliases: addresses:allocate
      DESC
      CLI.add_common_options()
      define_method "addresses:add" do
        begin
          compute_connection = connection(:compute, options)
          address = compute_connection.addresses.create
          display "Created a public IP address '#{address.ip}'."
        rescue Fog::HP::Errors::ServiceError, Fog::Compute::HP::Error => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        rescue Excon::Errors::RequestEntityTooLarge => error
          display_error_message(error, :rate_limited)
        end
      end

    end
  end
end

module HP
  module Cloud
    class CLI < Thor

      map %w(addresses:allocate) => 'addresses:add'

      desc "addresses:add", "add or allocate a new public IP address"
      long_desc <<-DESC
  Add or allocate a new public IP address from the pool of available IP addresses.

Examples:
  hpcloud addresses:add

Aliases: addresses:allocate
      DESC
      define_method "addresses:add" do
        begin
          compute_connection = connection(:compute)
          address = compute_connection.addresses.create
          display "Created a public IP address '#{address.ip}'."
        rescue Fog::Compute::HP::Error => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
      end

    end
  end
end
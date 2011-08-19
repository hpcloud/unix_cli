module HP
  module Cloud
    class CLI < Thor

      map %w(addresses:allocate) => 'addresses:add'

      desc "addresses:add", "allocate a new public IP address"
      long_desc <<-DESC
  Allocate a new public IP address from the pool of available IP addresses

Examples:
  hpcloud addresses:add

Aliases: addresses:allocate
      DESC
      define_method "addresses:add" do
        begin
          compute_connection = connection(:compute)
          address = compute_connection.addresses.new
          address.save
          display "Created a public IP address '#{address.public_ip}'."
          address.public_ip
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
      end

    end
  end
end
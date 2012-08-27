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
        cli_command(options) {
          compute_connection = connection(:compute, options)
          address = compute_connection.addresses.create
          display "Created a public IP address '#{address.ip}'."
        }
      end
    end
  end
end

module HP
  module Cloud
    class CLI < Thor

      map %w(addresses:allocate) => 'addresses:add'

      desc "addresses:add", "add or allocate a new public IP address"
      long_desc <<-DESC
  Add or allocate a new public IP address from the pool of available IP addresses.  Optionally, an availability zone can be passed.

Examples:
  hpcloud addresses:add
  hpcloud addresses:add -z az-2.region-a.geo-1

Aliases: addresses:allocate
      DESC
      CLI.add_common_options
      define_method "addresses:add" do
        cli_command(options) {
          address = AddressHelper.new(Connection.instance)
          if address.save
            display "Created a public IP address '#{address.ip}'."
          else
            error address.error_string, address.error_code
          end
        }
      end
    end
  end
end

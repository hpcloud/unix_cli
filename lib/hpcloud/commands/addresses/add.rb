module HP
  module Cloud
    class CLI < Thor

      map %w(addresses:allocate) => 'addresses:add'

      desc "addresses:add", "Add or allocate a new public IP address."
      long_desc <<-DESC
  Add or allocate a new public IP address from the pool of available IP addresses.  Optionally, you can set an availability zone.

Examples:
  hpcloud addresses:add # Add a new public IP address:
  hpcloud addresses:add -z az-2.region-a.geo-1 # Add a new public IP address in availability zone `az-2.region-a.geo-1`:

Aliases: addresses:allocate
      DESC
      CLI.add_common_options
      define_method "addresses:add" do
        cli_command(options) {
          address = AddressHelper.new(Connection.instance)
          if address.save
            @log.display "Created a public IP address '#{address.ip}'."
          else
            @log.fatal address.cstatus
          end
        }
      end
    end
  end
end

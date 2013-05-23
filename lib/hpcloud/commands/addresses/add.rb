module HP
  module Cloud
    class CLI < Thor

      map %w(addresses:allocate) => 'addresses:add'

      desc "addresses:add", "Add or allocate a new public IP address."
      long_desc <<-DESC
  Add or allocate a new public IP address from the pool of available IP addresses.  Optionally, you can set an availability zone.

Examples:
  hpcloud addresses:add netty # Add a new public IP address to network 'netty':
  hpcloud addresses:add netty -z az-2.region-a.geo-1 # Add a new public IP address in availability zone `az-2.region-a.geo-1`:

Aliases: addresses:allocate
      DESC
      method_option :network,
                    :type => :string, :aliases => '-n',
                    :desc => 'Name or id of the network associated with this IP.'
      method_option :port,
                    :type => :string, :aliases => '-p',
                    :desc => 'Name or id of the port associated with this IP.'
      method_option :fixed_ip,
                    :type => :string,
                    :desc => 'Fixed IP address to associate with this IP.'
      method_option :floating_ip,
                    :type => :string,
                    :desc => 'Floating IP to assign.'
      CLI.add_common_options
      define_method "addresses:add" do
        cli_command(options) {
          address = FloatingIpHelper.new(Connection.instance)
          address.set_network(options[:network])
          address.port = options[:port]
          address.fixed_ip = options[:fixed_ip]
          address.floating_ip = options[:floating_ip]
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

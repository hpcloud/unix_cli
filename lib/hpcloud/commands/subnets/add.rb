module HP
  module Cloud
    class CLI < Thor

      desc "subnets:add <name>", "Add a subnet."
      long_desc <<-DESC
  Add a new subnet in your account with the specified name.  Optionally, you can specify administrative state, or shared.

Examples:
  hpcloud subnets:add netty        # Create a new subnet named 'netty':
  hpcloud subnets:add netty -u -h  # Create a new subnet named 'netty' up and shared:
  hpcloud subnets:add netty --no-adminstateup  # Create a new subnet named 'netty' admin state down:
      DESC
      method_option :ipversion, :default => '6',
                    :type => :string, :aliases => '-i',
                    :desc => 'IP version.'
      method_option :gateway,
                    :type => :string, :aliases => '-g',
                    :desc => 'Gateway IP address.'
      method_option :dhcp, :default => true,
                    :type => :boolean, :aliases => '-d',
                    :desc => 'Enable DHCP.'
      CLI.add_common_options
      define_method "subnets:add" do |name, network, cidr|
        cli_command(options) {
          if Subnets.new.get(name).is_valid? == true
            @log.fatal "Subnet with the name '#{name}' already exists"
          end
          network = HP::Cloud::Networks.new.get(network)
          if network.is_valid? == false
            @log.fatal network.cstatus
          end

          subnet = HP::Cloud::SubnetHelper.new(Connection.instance)
          subnet.name = name
          subnet.network_id = network.id
          subnet.set_cidr(cidr)
          subnet.set_ip_version(options[:ipversion])
          subnet.set_gateway_ip(options[:gateway])
          subnet.enable_dhcp = options[:dhcp]
          if subnet.save == true
            @log.display "Created subnet '#{name}' with id '#{subnet.id}'."
          else
            @log.fatal subnet.cstatus
          end
        }
      end
    end
  end
end

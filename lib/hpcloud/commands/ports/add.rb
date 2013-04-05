module HP
  module Cloud
    class CLI < Thor

      desc "ports:add <name> <network_id_or_name>", "Add a port."
      long_desc <<-DESC
  Add a new port to your network with the specified name.  Optionally, you can specify fixed IPs, MAC address, administrative state, device identifier, device owner, and security groups.

Examples:
  hpcloud ports:add porto netty 127.0.0.0/24        # Create a new port named 'porto':
  hpcloud ports:add porto netty 127.0.0.0/24 -g groupo -u # Create a new port named 'porto' in 'groupo' administratively up:
      DESC
      method_option :fixedips,
                    :type => :string, :aliases => '-f',
                    :desc => 'Fixed IPs.'
      method_option :macaddress,
                    :type => :string, :aliases => '-m',
                    :desc => 'MAC address.'
      method_option :adminstate, :default => true,
                    :type => :boolean, :aliases => '-u',
                    :desc => 'Administrative state.'
      method_option :deviceid,
                    :type => :string, :aliases => '-d',
                    :desc => 'Device ID.'
      method_option :deviceowner,
                    :type => :string, :aliases => '-o',
                    :desc => 'Device owner.'
      method_option :securitygroups,
                    :type => :string, :aliases => '-g',
                    :desc => 'Security groups.'
      CLI.add_common_options
      define_method "ports:add" do |name, network|
        cli_command(options) {
          if Ports.new.get(name).is_valid? == true
            @log.fatal "Port with the name '#{name}' already exists"
          end
          network = HP::Cloud::Networks.new.get(network)
          if network.is_valid? == false
            @log.fatal network.cstatus
          end

          port = HP::Cloud::PortHelper.new(Connection.instance)
          port.name = name
          port.network_id = network.id
          port.set_fixed_ips(options[:fixedips])
          port.set_mac_address(options[:macaddress])
          port.set_admin_state(options[:adminstate])
          port.set_device_id(options[:deviceid])
          port.set_device_owner(options[:deviceowner])
          port.set_security_groups(options[:security_groups])
          if port.save == true
            @log.display "Created port '#{name}' with id '#{port.id}'."
          else
            @log.fatal port.cstatus
          end
        }
      end
    end
  end
end

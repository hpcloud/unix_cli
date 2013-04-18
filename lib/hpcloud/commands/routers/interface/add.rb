module HP
  module Cloud
    class CLI < Thor

      desc "routers:interface:add <router> <subnet_or_port>", "Add an interface to a router."
      long_desc <<-DESC
  Add an interface to your router with the specified subnet or port.

Examples:
  hpcloud routers:interface:add trout subnetty # Add an interface to the subnet 'subnetty':
  hpcloud routers:interface:add trout proto    # Add an interface to the port 'porto':
      DESC
      CLI.add_common_options
      define_method "routers:interface:add" do |name, subnet_or_port|
        cli_command(options) {
          router = Routers.new.get(name)
          unless router.is_valid?
            @log.fatal router.cstatus
          end
          subnet_id = nil
          port_id = nil
          subby = Subnets.new.get(subnet_or_port)
          if subby.is_valid?
            subnet_id = subby.id
            newinterface = subnet_id
          else
            porty = Ports.new.get(subnet_or_port)
            unless porty.is_valid?
              @log.fatal "Cannot find a subnet or port matching '#{subnet_or_port}'."
            end
            port_id = porty.id
            newinterface = port_id
          end

          Connection.instance.network.add_router_interface(router.id, subnet_id, port_id)
          @log.display "Created router interface '#{name}' to '#{newinterface}'."
        }
      end
    end
  end
end

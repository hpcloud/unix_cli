module HP
  module Cloud
    class CLI < Thor

      map %w(routers:interface:rm routers:interface:delete routers:interface:del) => 'routers:interface:remove'

      desc "routers:interface:remove <router_name_or_id> <subnet_or_port>", "Remove router interface."
      long_desc <<-DESC
  Remove router port or subnet router interface from router.

Examples:
  hpcloud routers:interface:remove trout puerto   # Delete port 'puerto' from 'trout'
  hpcloud routers:interface:remove trout netty    # Delete subnet 'netty' from 'trout'

Aliases: routers:interface:rm, routers:interface:delete, routers:interface:del
      DESC
      CLI.add_common_options
      define_method "routers:interface:remove" do |name, subnet_or_port|
        cli_command(options) {
          router = Routers.new.get(name)
          subnet_id = nil
          port_id = nil
          word = ""
          subby = Subnets.new.get(subnet_or_port)
          if subby.is_valid?
            subnet_id = subby.id
            oldinterface = subnet_id
            word = "subnet"
          else
            porty = Ports.new.get(subnet_or_port)
            unless porty.is_valid?
              @log.fatal "Cannot find a subnet or port matching '#{subnet_or_port}'."
            end
            port_id = porty.id
            oldinterface = port_id
            word = "port"
          end

          Connection.instance.network.remove_router_interface(router.id, subnet_id, port_id)
          @log.display "Removed #{word} interface '#{subnet_or_port}' from '#{name}'."
        }
      end
    end
  end
end

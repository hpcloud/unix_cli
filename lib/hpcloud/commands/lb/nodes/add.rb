
module HP
  module Cloud
    class CLI < Thor

      desc "lb:nodes:add <load_balancer_name_or_id> <address> <port>", "Add a node to the load balancer."
      long_desc <<-DESC
  Add a node to the load balancer with the specified adddress and port.

Examples:
  hpcloud lb:nodes:add loady 10.1.1.1 80  # Create a new node for load balancer 'loady'
      DESC
      define_method "lb:nodes:add" do |load_balancer_name_or_id, address, port|
        cli_command(options) {
          lb = Lbs.new.get(load_balancer_name_or_id)
          node = Fog::HP::LB::Node.new({:service => Connection.instance.lb})
          node.address = address
          node.port = port
          if node.save == true
            @log.display "Created node '#{name}' with id '#{node.id}'."
          else
            @log.fatal lb.cstatus
          end
        }
      end
    end
  end
end

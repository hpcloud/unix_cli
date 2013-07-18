
module HP
  module Cloud
    class CLI < Thor

      desc "lb:nodes:add <lb_name_or_id> <address> <port>", "Add a node to the load balancer."
      long_desc <<-DESC
  Add a node to the load balancer with the specified adddress and port.

Examples:
  hpcloud lb:nodes:add loady 10.1.1.1 80  # Create a new node for load balancer 'loady'
      DESC
      CLI.add_common_options
      define_method "lb:nodes:add" do |load_balancer_name_or_id, address, port|
        cli_command(options) {
          lb = Lbs.new.get(load_balancer_name_or_id)
          node = Fog::HP::LB::Node.new({:service => Connection.instance.lb, :load_balancer_id => lb.id})
          node.address = address
          node.port = port
          node.save
          @log.display "Created node '#{address}:#{port}' with id '#{node.id}'."
        }
      end
    end
  end
end
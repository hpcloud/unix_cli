require 'hpcloud/lb_nodes'

module HP
  module Cloud
    class CLI < Thor

      map 'lb:nodes:list' => 'lb:nodes'
    
      desc 'lb:nodes name_or_id', "List the nodes associated with the specified load balancer."
      long_desc <<-DESC
  Lists all the nodes associated with the specified load balancer. The list begins with identifier and address, port, condition and status.

Examples:
  hpcloud lb:nodes balancer   # List all nodes for load balancer 'balancer':

Aliases: lb:nodes:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      define_method "lb:nodes" do |name_or_id|
        columns = [ "id", "address", "port", "condition", "status" ]
        cli_command(options) {
          lb = Lbs.new.get(name_or_id)
          nodes = LbNodes.new(lb.id).get
          ray = nodes.get_array
          if ray.empty?
            @log.display "There are no load balancers that match the provided arguments"
          else
            Tableizer.new(options, columns, ray).print
          end
        }
      end
    end
  end
end

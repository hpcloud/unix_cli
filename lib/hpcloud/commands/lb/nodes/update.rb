
module HP
  module Cloud
    class CLI < Thor

      desc "lb:nodes:update <lb_name_or_id> <name_or_id> <condition>", "Update a node in a load balancer."
      long_desc <<-DESC
  Update a node in a load balancer with the specified condition.  The id of the node may be used or 'address:port'.

Examples:
  hpcloud lb:nodes:update loady 10.1.1.1:80 DISABLED # Update node '10.1.1.1:80' to 'DISABLED'
  hpcloud lb:nodes:update 220303 1027580 ENABLED # Update node '1027580' to 'ENABLED'
      DESC
      CLI.add_common_options
      define_method "lb:nodes:update" do |lb_name_or_id, name_or_id, condition|
        cli_command(options) {
          lb = Lbs.new.get(lb_name_or_id)
          node = LbNodes.new(lb.id).get(name_or_id, false)
          node.condition = condition
          node.save
          @log.display "Updated node '#{name_or_id}' to '#{condition}'."
        }
      end
    end
  end
end

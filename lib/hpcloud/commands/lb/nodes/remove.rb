module HP
  module Cloud
    class CLI < Thor

      map %w(lb:nodes:rm lb:nodes:delete lb:nodes:del) => 'lb:nodes:remove'

      desc "lb:nodes:remove lb_name_or_id node_id [node_id ...]", "Remove the specified load balancer nodes."
      long_desc <<-DESC
  Remove load balancer node by specifying the name or id of the load balancer and the id of the nodes.

Examples:
  hpcloud lb:nodes:remove scale 1044952   # Delete the load balancers ndoe `1044952` from `scale`

Aliases: lb:nodes:rm, lb:nodes:delete, lb:nodes:del
      DESC
      CLI.add_common_options
      define_method "lb:nodes:remove" do |lb_name_or_id, name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          lb = Lbs.new.get(lb_name_or_id)
          name_or_ids.each{ |name|
            sub_command("removing load balancer node") {
              node = LbNodes.new(lb.id).get(name, false)
              node.load_balancer_id = lb.id
              node.destroy
              @log.display "Removed node '#{name}' from load balancer '#{lb_name_or_id}'."
            }
          }
        }
      end
    end
  end
end

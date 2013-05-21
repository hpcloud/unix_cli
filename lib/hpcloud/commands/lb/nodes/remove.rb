module HP
  module Cloud
    class CLI < Thor

      map %w(lb:nodes:rm lb:nodes:delete lb:nodes:del) => 'lb:nodes:remove'

      desc "lb:nodes:remove name_or_id address port", "Remove the specified load balancer node."
      long_desc <<-DESC
  Remove load balancer node by specifying the name or id of the load balancer, the address and the port.

Examples:
  hpcloud lb:remove thing1 10.2.2.2 80   # Delete the load balancers `thing1` and `thing2`:

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

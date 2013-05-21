
module HP
  module Cloud
    class CLI < Thor

      desc "lb:update <lb_name_or_id> <name_or_id> <algorithm>", "Update a node in a load balancer."
      long_desc <<-DESC
  Update a load balancer with the specified algorithm.  The name or id of the load balancer may be used to identify it.

Examples:
  hpcloud lb:update loady ROUND_ROBIN # Update node 'loady' to 'ROUND_ROBIN'
  hpcloud lb:update 220303 LEAST_CONNECTIONS # Update node '220303' to 'LEAST_CONNECTIONS'
      DESC
      CLI.add_common_options
      define_method "lb:update" do |name_or_id, algorithm|
        cli_command(options) {
          lb = Lbs.new.get(name_or_id)
          lb.algorithm = algorithm
          lb.save
          @log.display "Updated load balancer '#{name_or_id}' to '#{algorithm}'."
        }
      end
    end
  end
end

module HP
  module Cloud
    class CLI < Thor

      map %w(lb:rm lb:delete lb:del) => 'lb:remove'

      desc "lb:remove name_or_id [name_or_id ...]", "Remove load balancer (specified by name or ID)."
      long_desc <<-DESC
  Remove load balancers by specifying their names or ID. You may specify more than one load balacner name or ID on a command line.

Examples:
  hpcloud lb:remove thing1 thing2   # Delete the load balancers `thing1` and `thing2`:
  hpcloud lb:remove 998             # Delete the load balancer with ID 998:

Aliases: lb:rm, lb:delete, lb:del
      DESC
      CLI.add_common_options
      define_method "lb:remove" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          lbs = Lbs.new
          name_or_ids.each{ |name|
            sub_command("removing load balancer") {
              lb = lbs.get(name, false)
              lb.destroy
              @log.display "Removed load balancer '#{lb.name}'."
            }
          }
        }
      end
    end
  end
end

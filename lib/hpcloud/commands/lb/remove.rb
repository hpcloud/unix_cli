module HP
  module Cloud
    class CLI < Thor

      map %w(lb:rm lb:delete lb:del) => 'lb:remove'

      desc "lb:remove name_or_id [name_or_id ...]", "Remove DNS domains (specified by name or ID)."
      long_desc <<-DESC
  Remove DNS domains by specifying their names or ID. You may specify more than one DNS name or ID on a command line.  Optionally, you can specify an availability zone.

Examples:
  hpcloud lb:remove tome treatise   # Delete the DNS domains `tome` and `treatise`:
  hpcloud lb:remove 998             # Delete the DNS domain with ID 998:
  hpcloud lb:remove my-lb -z az-2.region-a.geo-1  # Delete the DNS domain `my-lb` for availability zone `az-2.region-a.geo-1`:

Aliases: lb:rm, lb:delete, lb:del
      DESC
      CLI.add_common_options
      define_method "lb:remove" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          name_or_ids.each{ |name|
            lbs = Lbs.new
            sub_command("removing lb") {
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

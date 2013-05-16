require 'hpcloud/lb_limits'

module HP
  module Cloud
    class CLI < Thor
      desc 'lb:limits', "List the available load balancer limits."
      long_desc <<-DESC
  Lists all the available load balancers limits.

Examples:
  hpcloud lb:limits          # List all limits:

Aliases: lb:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      define_method "lb:limits" do
        columns = [ "max_load_balancer_name_length", "max_load_balancers", "max_nodes_per_load_balancer", "max_vips_per_load_balancer" ]

        cli_command(options) {
          filter = LbLimits.new
          if filter.empty?
            @log.display "There don't seem to be any supported limits at the moment"
          else
            ray = filter.get_array
            if ray.empty?
              @log.display "No limits were found"
            else
              Tableizer.new(options, columns, ray).print
            end
          end
        }
      end
    end
  end
end

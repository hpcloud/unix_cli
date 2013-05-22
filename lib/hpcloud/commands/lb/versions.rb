require 'hpcloud/lb_versions'

module HP
  module Cloud
    class CLI < Thor
      desc 'lb:versions', "List the available load balancer versions."
      long_desc <<-DESC
  Lists all the available load balancers versions.

Examples:
  hpcloud lb:versions          # List all versions:
      DESC
      CLI.add_report_options
      CLI.add_common_options
      define_method "lb:versions" do
        columns = [ "id", "status", "updated" ]

        cli_command(options) {
          filter = LbVersions.new
          if filter.empty?
            @log.display "There don't seem to be any supported versions at the moment"
          else
            ray = filter.get_array
            if ray.empty?
              @log.display "No versions were found"
            else
              Tableizer.new(options, columns, ray).print
            end
          end
        }
      end
    end
  end
end

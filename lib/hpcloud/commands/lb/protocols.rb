require 'hpcloud/lb_protocols'

module HP
  module Cloud
    class CLI < Thor
      desc 'lb:protocols', "List the available load balancer protocols."
      long_desc <<-DESC
  Lists all the available load balancers protocols.

Examples:
  hpcloud lb:protocols          # List all protocols
      DESC
      CLI.add_report_options
      CLI.add_common_options
      define_method "lb:protocols" do |*arguments|
        columns = [ "name", "port" ]

        cli_command(options) {
          filter = LbProtocols.new
          if filter.empty?
            @log.display "There don't seem to be any supported protocols at the moment"
          else
            ray = filter.get_array(arguments)
            if ray.empty?
              @log.display "There are no protocols that match the provided arguments"
            else
              Tableizer.new(options, columns, ray).print
            end
          end
        }
      end
    end
  end
end

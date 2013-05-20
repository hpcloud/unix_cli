require 'hpcloud/lb_algorithms'

module HP
  module Cloud
    class CLI < Thor
      desc 'lb:algorithms', "List the available load balancer algorithms."
      long_desc <<-DESC
  Lists all the available load balancers algorithms.

Examples:
  hpcloud lb:algorithms          # List all algorithms:
      DESC
      CLI.add_report_options
      CLI.add_common_options
      define_method "lb:algorithms" do |*arguments|
        columns = [ "name" ]

        cli_command(options) {
          algo = LbAlgorithms.new
          if algo.empty?
            @log.display "There don't seem to be any supported algorithms at the moment"
          else
            ray = algo.get_array(arguments)
            if ray.empty?
              @log.display "There are no algorithms that match the provided arguments"
            else
              Tableizer.new(options, columns, ray).print
            end
          end
        }
      end
    end
  end
end

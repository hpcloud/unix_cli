require 'hpcloud/lb_algorithms'
require 'hpcloud/lb_algorithms_helper'

module HP
  module Cloud
    class CLI < Thor
      desc 'lb:algorithms', "List the available load balancer algorithms."
      long_desc <<-DESC
  Lists all the available load balancers algorithms.

Examples:
  hpcloud lb:algorithm          # List all algorithms:

Aliases: lb:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      define_method "lb:algorithms" do |*arguments|
        DEFAULT_KEYS = [ "name" ]

        cli_command(options) {
          algo = LbAlgorithms.new
          if algo.empty?
            @log.display "There don't seem to be any supported algorithms at the moment"
          else
            ray = algo.get_array(arguments)
            if ray.empty?
              @log.display "There are no load balancers that match the provided arguments"
            else
              Tableizer.new(options, DEFAULT_KEYS, ray).print
            end
          end
        }
      end
    end
  end
end

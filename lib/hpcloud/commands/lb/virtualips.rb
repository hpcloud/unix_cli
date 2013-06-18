require 'hpcloud/lb_virtualips'

module HP
  module Cloud
    class CLI < Thor
      desc 'lb:virtualips name_or_id', "List the virtual IPs for the specified load balancer."
      long_desc <<-DESC
  Lists the virtual IPs for the specified load balancer.

Examples:
  hpcloud lb:virtualips loader   # List the virtual IPs for 'loader'
      DESC
      CLI.add_report_options
      CLI.add_common_options
      define_method "lb:virtualips" do |name_or_id|
        columns = [ "id", "address", "ipVersion", "type" ]

        cli_command(options) {
          lb = Lbs.new.get(name_or_id)
          ray = LbVirtualIps.new(lb.id).get_array
          if ray.empty?
            @log.display "There are no virtual IPs for the given load balancer."
          else
            Tableizer.new(options, columns, ray).print
          end
        }
      end
    end
  end
end

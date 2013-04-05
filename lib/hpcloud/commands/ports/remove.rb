module HP
  module Cloud
    class CLI < Thor

      map %w(ports:rm ports:delete ports:del) => 'ports:remove'

      desc "ports:remove name_or_id [name_or_id ...]", "Remove a port (specified by name or ID)."
      long_desc <<-DESC
  Remove port by specifying their names or ID. You may specify more than one port name or ID on a command line.

Examples:
  hpcloud ports:remove blue red   # Delete the port 'blue' and 'red':
  hpcloud ports:remove 998        # Delete the port with ID 998:
  hpcloud ports:remove netty -z region-a.geo-1  # Delete the port `netty` for availability zone `region-a.geo-1`:

Aliases: ports:rm, ports:delete, ports:del
      DESC
      CLI.add_common_options
      define_method "ports:remove" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          ports = Ports.new.get(name_or_ids, false)
          ports.each { |port|
            sub_command("removing port") {
              if port.is_valid?
                port.destroy
                @log.display "Removed port '#{port.name}'."
              else
                @log.error port.cstatus
              end
            }
          }
        }
      end
    end
  end
end

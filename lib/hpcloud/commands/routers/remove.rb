module HP
  module Cloud
    class CLI < Thor

      map %w(routers:rm routers:delete routers:del) => 'routers:remove'

      desc "routers:remove name_or_id [name_or_id ...]", "Remove a router (specified by name or ID)."
      long_desc <<-DESC
  Remove router by specifying their names or ID. You may specify more than one router name or ID on a command line.

Examples:
  hpcloud routers:remove blue red   # Delete the router 'blue' and 'red':
  hpcloud routers:remove 998          # Delete the router with ID 998:
  hpcloud routers:remove netty -z region-a.geo-1  # Delete the router `netty` for availability zone `region-a.geo-1`:

Aliases: routers:rm, routers:delete, routers:del
      DESC
      CLI.add_common_options
      define_method "routers:remove" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          routers = Routers.new.get(name_or_ids, false)
          routers.each { |router|
            sub_command("removing router") {
              if router.is_valid?
                router.destroy
                @log.display "Removed router '#{router.name}'."
              else
                @log.error router.cstatus
              end
            }
          }
        }
      end
    end
  end
end

module HP
  module Cloud
    class CLI < Thor

      map %w(routers:rm routers:delete routers:del) => 'routers:remove'

      desc "routers:remove name_or_id [name_or_id ...]", "Remove a router (specified by name or ID)."
      long_desc <<-DESC
  Remove router by specifying their names or ID. You may specify more than one router name or ID on a command line.

Examples:
  hpcloud routers:remove blue red   # Delete the router 'blue' and 'red'
  hpcloud routers:remove 39e36520   # Delete the router with ID 39e36520

Aliases: routers:rm, routers:delete, routers:del
      DESC
      CLI.add_common_options
      define_method "routers:remove" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          routers = Routers.new
          name_or_ids.each{ |name|
            sub_command("removing router") {
              router = routers.get(name, false)
              router.destroy
              @log.display "Removed router '#{router.name}'."
            }
          }
        }
      end
    end
  end
end

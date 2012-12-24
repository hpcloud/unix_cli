module HP
  module Cloud
    class CLI < Thor

      map 'servers:metadata:rm' => 'servers:metadata:remove'

      desc "servers:metadata:remove <name> <metadata_key> ...", "Remove metadata from a server."
      long_desc <<-DESC
  Remove metadata from a server in your compute account.  You can speciry the erver name or ID.  You can specify one or more metadata keys on the command line.  Optionally, you can specify an availability zone.

Examples:
  hpcloud servers:metadata:remove :my_server r2 c3  # Remove the the r2 and c3 metadata from the server:

Aliases: servers:metadata:rm
      DESC
      CLI.add_common_options
      define_method "servers:metadata:remove" do |name_or_id, *metadata|
        cli_command(options) {
          server = Servers.new.get(name_or_id)
          if server.is_valid? == false
            @log.fatal server.cstatus
          else
            metadata.each { |key|
              if server.meta.remove_metadata(key)
                @log.display "Removed metadata '#{key}' from server '#{name_or_id}'."
              else
                @log.error server.meta.cstatus
              end
            }
          end
        }
      end
    end
  end
end

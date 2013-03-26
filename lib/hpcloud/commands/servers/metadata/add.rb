module HP
  module Cloud
    class CLI < Thor

      map 'servers:metadata:update' => 'servers:metadata:add'

      desc "servers:metadata:add <name_or_id> <metadata>", "Add metadata to a server."
      long_desc <<-DESC
  Add metadata to a server in your compute account.  You can specify the erver name or ID.  Optionally, you can an availability zone. The metadata should be a comma separated list of name value pairs.

Examples:
  hpcloud servers:metadata:add my_server 'r2=d2,c3=po'  # Add the specified metadata to the server (if the metadata exists, it is updated):

Aliases: servers:metadata:update
      DESC
      CLI.add_common_options
      define_method "servers:metadata:add" do |name_or_id, metadata|
        cli_command(options) {
          server = Servers.new.get(name_or_id.to_s)
          if server.is_valid? == false
            @log.fatal server.cstatus
          else
            if server.meta.set_metadata(metadata)
              @log.display "Server '#{name_or_id}' set metadata '#{metadata}'."
            else
              @log.fatal server.meta.cstatus
            end
          end

        }
      end
    end
  end
end

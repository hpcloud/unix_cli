require 'hpcloud/servers'
require 'hpcloud/metadata'

module HP
  module Cloud
    class CLI < Thor

      map 'servers:metadata:list' => 'servers:metadata'

      desc "servers:metadata <name_or_id>", "List the metadata for a server."
      long_desc <<-DESC
  List the metadata for a server in your compute account. You can specify either the name or the ID of the server.  Optionally, you can specify an availability zone.

Examples:
  hpcloud servers:metadata Skynet                        # List server metadata:
  hpcloud servers:metadata -z az-2.region-a.geo-1 565394 # List server metadata for availability zone `az-2region-a.geo-1`:

Aliases: servers:metadata:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      define_method "servers:metadata" do |name_or_id|
        cli_command(options) {
          server = Servers.new.get(name_or_id)
          if server.is_valid?
            ray = server.meta.to_array()
            Tableizer.new(options, Metadata.get_keys(), ray).print
          else
            @log.fatal server.cstatus
          end
        }
      end
    end
  end
end

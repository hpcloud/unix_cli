require 'hpcloud/servers'
require 'hpcloud/metadata'

module HP
  module Cloud
    class CLI < Thor

      map 'servers:metadata:list' => 'servers:metadata'

      desc "servers:metadata <serverName|serverId>", "list metadata for a server"
      long_desc <<-DESC
  List the metadata for a server in your compute account. You may specify either the name or the id of the server.  Optionally, an availability zone can be passed.

Examples:
  hpcloud servers:metadata Skynet                        # List server metadata
  hpcloud servers:metadata -z az-2.region-a.geo-1 565394 # List server metadata for an availability zone

Aliases: servers:metadata:list
      DESC
      GOPTS.each { |k,v| method_option(k, v) }
      define_method "servers:metadata" do |name_or_id|
        begin
          Connection.instance.set_options(options)
          server = Servers.new.get(name_or_id)
          if server.is_valid?
            tablelize(server.meta.to_hash(), Metadata.get_keys())
          else
            error server.error_string, server.error_code
          end
        rescue Fog::HP::Errors::ServiceError, Fog::Compute::HP::Error => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
      end

    end
  end
end

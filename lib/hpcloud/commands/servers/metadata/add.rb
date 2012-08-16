module HP
  module Cloud
    class CLI < Thor

      map 'servers:metadata:update' => 'servers:metadata:add'

      desc "servers:metadata:add <name|id> <metadata>", "add metadata to a server"
      long_desc <<-DESC
  Add metadata to a server in your compute account.  Server name or id may be specified.  Optionally, an availability zone can be passed in. The metadata should be a comma separated list of name value pairs.

Examples:
  hpcloud servers:metadata:add my_server 'r2=d2,c3=po'  # Adds the specified metadata to the server.  If the metadata exists, it will be updated.

Aliases: servers:metadata:update
      DESC
      GOPTS.each { |k,v| method_option(k, v) }
      define_method "servers:metadata:add" do |name_or_id, metadata|
        begin
          Connection.instance.set_options(options)
          server = Servers.new.get(name_or_id.to_s)
          if server.is_valid? == false
            error server.error_string, server.error_code
          else
            if server.meta.set_metadata(metadata)
              display "Server '#{name_or_id}' set metadata '#{metadata}'."
            else
              error(server.meta.error_string, server.meta.error_code)
            end
          end

        rescue Fog::HP::Errors::ServiceError, Excon::Errors::BadRequest, Fog::Compute::HP::Error => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        rescue Excon::Errors::RequestEntityTooLarge => error
          display_error_message(error, :rate_limited)
        end
      end
    end
  end
end

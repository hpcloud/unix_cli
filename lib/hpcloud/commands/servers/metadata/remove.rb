module HP
  module Cloud
    class CLI < Thor

      map 'servers:metadata:rm' => 'servers:metadata:remove'

      desc "servers:metadata:remove <name> <metadata_key> ...", "remove metadata from a server"
      long_desc <<-DESC
  Remove metadata from a server in your compute account.  Server name or id can be specified.  One or more metadata keys may be specified on the command line.  Optionally, an availability zone can be passed.

Examples:
  hpcloud servers:metadata:remove :my_server r2 c3  # Remove the the r2 and c3 metadata from the server.

Aliases: servers:metadata:rm
      DESC
      GOPTS.each { |k,v| method_option(k, v) }
      define_method "servers:metadata:remove" do |name_or_id, *metadata|
        begin
          Connection.instance.set_options(options)
          server = Servers.new.get(name_or_id)
          if server.is_valid? == false
            error server.error_string, server.error_code
          else
            metadata.each { |key|
              if server.meta.remove_metadata(key)
                display "Removed metadata '#{key}' from server '#{name_or_id}'."
              else
                error_message(server.meta.error_string, server.meta.error_code)
              end
            }
            exit @exit_status || 0
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

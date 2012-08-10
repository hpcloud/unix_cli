module HP
  module Cloud
    class CLI < Thor

      map %w(servers:rm servers:delete servers:del) => 'servers:remove'

      desc "servers:remove <name>", "remove a server by name"
      long_desc <<-DESC
  Remove an existing server by specifying its name. Optionally, an availability zone can be passed.

Examples:
  hpcloud servers:remove my-server          # delete 'my-server'
  hpcloud servers:remove my-server -z az-2.region-a.geo-1  # Optionally specify an availability zone

Aliases: servers:rm, servers:delete, servers:del
      DESC
      method_option :availability_zone,
                    :type => :string, :aliases => '-z',
                    :desc => 'Set the availability zone.'
      define_method "servers:remove" do |*names|
        names.each { |name|
          begin
            # setup connection for compute service
            compute_connection = connection(:compute, options)
            server = compute_connection.servers.select {|s| s.name == name}.first
            if (server && server.name == name)
              # now delete the server
              server.destroy
              display "Removed server '#{name}'."
            else
              error "You don't have a server '#{name}'.", :not_found
            end
          rescue Fog::HP::Errors::ServiceError, Fog::Compute::HP::Error, Excon::Errors::BadRequest, Excon::Errors::InternalServerError => error
            display_error_message(error, :general_error)
          rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden, Excon::Errors::Conflict => error
            display_error_message(error, :permission_denied)
          end
        }
      end

    end
  end
end

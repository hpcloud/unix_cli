module HP
  module Cloud
    class CLI < Thor

      desc "images:add <name> <server_name>", "add an image from an existing server"
      long_desc <<-DESC
  Add a new image from an existing server to your compute account. Optionally, an availability zone can be passed.

Examples:
  hpcloud images:add my_image my_server                           # Creates a new image named 'my_image' from an existing server named 'my_server'
  hpcloud images:add my_image my_server -z az-2.region-a.geo-1    # Optionally specify an availability zone

Aliases: none
      DESC
      method_option :availability_zone,
                    :type => :string, :aliases => '-z',
                    :desc => 'Set the availability zone.'
      define_method "images:add" do |name, server_name|
        # setup connection for compute service
        begin
          compute_connection = connection(:compute, options)
          server = compute_connection.servers.select {|s| s.name == server_name}.first
          unless server.nil?
            resp = server.create_image(name)
            # extract the new image id from the header
            new_image_id = resp.headers["Location"].split("/")[5]
            display "Created image '#{name}' with id '#{new_image_id}'."
          else
            error "You don't have a server '#{server_name}' to create the image from.", :not_found
          end
        rescue Fog::HP::Errors::ServiceError, Fog::Compute::HP::Error => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden, Excon::Errors::Conflict => error
          display_error_message(error, :permission_denied)
        end
      end

    end
  end
end
module HP
  module Cloud
    class CLI < Thor

      desc "images:add <name> <server_name>", "add an image from an existing server"
      long_desc <<-DESC
  Add a new image from an existing server to your compute account.

Examples:
  hpcloud images:add my_image my_server       # Creates a new image named 'my_image' from an existing server named 'my_server' \n

Aliases: none
      DESC
      define_method "images:add" do |name, server_name|
        # setup connection for compute service
        compute_connection = connection(:compute)
        begin
          server = compute_connection.servers.select {|s| s.name == server_name}.first
          unless server.nil?
            resp = server.create_image(name)
            # extract the new image id from the header
            new_image_id = resp.headers["Location"].split("/")[5]
            display "Created image #{name} with id '#{new_image_id}'."
          else
            error "You don't have a server '#{server_name}' to create the image from.", :not_found
          end
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden, Excon::Errors::Conflict => error
          display_error_message(error, :permission_denied)
        end
      end

    end
  end
end
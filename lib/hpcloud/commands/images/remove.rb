module HP
  module Cloud
    class CLI < Thor

      map %w(images:delete images:del) => 'images:remove'

      desc "images:remove <name>", "remove an image by name"
      long_desc <<-DESC
  Remove an existing image by specifying its name.

Examples:
  hpcloud images:remove my-image          # delete 'my-image'

Aliases: images:delete, images:del
      DESC
      define_method "images:remove" do |name|
        begin
          # setup connection for compute service
          compute_connection = connection(:compute)
          image = compute_connection.images.select {|i| i.name == name}.first
        rescue Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
        if (image && image.name == name)
          begin
            # now delete the image
            image.destroy
            display "Removed image '#{name}'."
          rescue Excon::Errors::Conflict, Excon::Errors::Forbidden => error
            display_error_message(error)
          end
        else
          error "You don't have an image '#{name}'.", :not_found
        end
      end

    end
  end
end
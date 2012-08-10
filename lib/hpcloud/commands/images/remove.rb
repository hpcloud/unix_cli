module HP
  module Cloud
    class CLI < Thor

      map %w(images:rm images:delete images:del) => 'images:remove'

      desc "images:remove <name>", "remove an image by name"
      long_desc <<-DESC
  Remove an existing image by specifying its name. Optionally, an availability zone can be passed.

Examples:
  hpcloud images:remove my-image                           # delete 'my-image'
  hpcloud images:remove my-image -z az-2.region-a.geo-1    # Optionally specify an availability zone

Aliases: images:rm, images:delete, images:del
      DESC
      method_option :availability_zone,
                    :type => :string, :aliases => '-z',
                    :desc => 'Set the availability zone.'
      define_method "images:remove" do |*names|
        begin
          # setup connection for compute service
          compute_connection = connection(:compute, options)
          names.each { |name|
            image = compute_connection.images.select {|i| i.name == name}.first
            if (image && image.name == name)
                # now delete the image
                image.destroy
                display "Removed image '#{name}'."
            else
              error "You don't have an image '#{name}'.", :not_found
            end
          }
        rescue Fog::HP::Errors::ServiceError, Fog::Compute::HP::Error => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden, Excon::Errors::Conflict => error
          display_error_message(error, :permission_denied)
        end
      end

    end
  end
end

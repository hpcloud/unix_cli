module HP
  module Cloud
    class CLI < Thor

      map 'images:metadata:update' => 'images:metadata:add'

      desc "images:metadata:add <name> <metadata>", "add metadata to an image"
      long_desc <<-DESC
  Add metadata to a image in your compute account.  Image name or id may be specified.  If metadata already exists, it will be updated.  Metadata should be specified as a comma separated list of name value pairs.  Optionally, an availability zone can be passed.

Examples:
  hpcloud images:metadata:add my_image 'r2=d2,c3=po'  # Adds the specified metadata to the image.  If the metadata exists, it will be updated.

Aliases: images:metadata:update
      DESC
      method_option :availability_zone,
                    :type => :string, :aliases => '-z',
                    :desc => 'Set the availability zone.'
      define_method "images:metadata:add" do |name_or_id, metadata|
        begin
          Connection.instance.set_options(options)
          image = Images.new.get(name_or_id.to_s)
          if image.is_valid?
            if image.meta.set_metadata(metadata)
              display "Image '#{name_or_id}' set metadata '#{metadata}'."
            else
              error(image.meta.error_string, image.meta.error_code)
            end
          else
            error(image.error_string, image.error_code)
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

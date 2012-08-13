module HP
  module Cloud
    class CLI < Thor

      map 'images:metadata:rm' => 'images:metadata:remove'

      desc "images:metadata:remove <name> <metadata>", "remove metadata from a image"
      long_desc <<-DESC
  Remove metadata from an image in your compute account.  Image name or id may be specified.  Optionally, an availability zone can be passed.

Examples:
  hpcloud images:metadata:remove my_image r2 c3  # Remove the specified metadata from the image.

Aliases: rm
      DESC
      method_option :availability_zone,
                    :type => :string, :aliases => '-z',
                    :desc => 'Set the availability zone.'
      define_method "images:metadata:remove" do |name_or_id, *metadata|
        begin
          Connection.instance.set_options(options)
          image = Images.new.get(name_or_id.to_s)
          if image.is_valid?
            metadata.each { |key|
              if image.meta.remove_metadata(key)
                display "Removed metadata '#{key}' from image '#{name_or_id}'."
              else
                error_message(image.meta.error_string, image.meta.error_code)
              end
            }
            exit @exit_status || 0
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

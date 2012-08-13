module HP
  module Cloud
    class CLI < Thor

      map 'volumes:metadata:update' => 'volumes:metadata:add'

      desc "volumes:metadata:add <name|id> <metadata>", "add metadata to a volume"
      long_desc <<-DESC
  Add metadata to a volume in your compute account.  Volume name or id may be specified.  Optionally, an availability zone can be passed in. The metadata should be a comma separated list of name value pairs.

Examples:
  hpcloud volumes:metadata:add my_volume 'r2=d2,c3=po'  # Adds the specified metadata to the volume.  If the metadata exists, it will be updated.

Aliases: volumes:metadata:update
      DESC
      method_option :availability_zone,
                    :type => :string, :aliases => '-z',
                    :desc => 'Set the availability zone.'
      define_method "volumes:metadata:add" do |name_or_id, metadata|
        begin
          Connection.instance.set_options(options)
          volume = Volumes.new.get(name_or_id.to_s)
          if volume.is_valid? == false
            error volume.error_string, volume.error_code
          else
            if volume.meta.set_metadata(metadata)
              display "Volume '#{name_or_id}' set metadata '#{metadata}'."
            else
              error(volume.meta.error_string, volume.meta.error_code)
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

module HP
  module Cloud
    class CLI < Thor

      map %w(volumes:rm volumes:delete volumes:del) => 'volumes:remove'

      desc "volumes:remove <id|name> ...", "remove a volume by id or name"
      long_desc <<-DESC
  Remove volumes by specifying their names or ids. Optionally, an availability zone may be passed.

Examples:
  hpcloud volumes:remove my-volume 998                     # delete 'my-volume' and 998
  hpcloud volumes:remove my-volume -z az-2.region-a.geo-1  # Optionally specify an availability zone

Aliases: volumes:rm, volumes:delete, volumes:del
      DESC
      method_option :availability_zone,
                    :type => :string, :aliases => '-z',
                    :desc => 'Set the availability zone.'
      define_method "volumes:remove" do |*names|
        begin
          Connection.instance.set_options(options)
          volumes = Volumes.new.get(names, false)
          volumes.each { |volume|
            if volume.is_valid?
              volume.destroy
              display "Removed volume '#{volume.name}'."
            else
              error volume.error_string, volume.error_code
            end
          }
        rescue Fog::HP::Errors::ServiceError, Fog::Compute::HP::Error, Excon::Errors::BadRequest, Excon::Errors::InternalServerError => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden, Excon::Errors::Conflict => error
          display_error_message(error, :permission_denied)
        end
      end

    end
  end
end

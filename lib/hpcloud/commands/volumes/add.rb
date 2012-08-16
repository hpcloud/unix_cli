module HP
  module Cloud
    class CLI < Thor

      desc "volumes:add <name> <size>", "add a volume"
      long_desc <<-DESC
  Add a new volume to your compute account with the specified name and size.  Optionally, a description, metadata or availability zone may be specified.

Examples:
  hpcloud volumes:add :my_volume 10               # Creates a new volume named 'my_volume' using an image and flavor \n
  hpcloud volumes:add :my_volume 10 -d 'test vol' # Creates a new volume named 'my_volume' using an image, flavor and a key \n
  hpcloud volumes:add :my_volume 7 1 -z az-2.region-a.geo-1  # Optionally specify an availability zone

Aliases: none
      DESC
      method_option :description,
                    :type => :string, :aliases => '-d',
                    :desc => 'Description of the volume.'
      method_option :metadata,
                    :type => :string, :aliases => '-m',
                    :desc => 'Set the meta data.'
      method_option :availability_zone,
                    :type => :string, :aliases => '-z',
                    :desc => 'Set the availability zone.'
      define_method "volumes:add" do |name, size|
        Connection.instance.set_options(options)
        begin
          if Volumes.new.get(name).is_valid? == true
            error "Volume with the name '#{name}' already exists", :general_error
          end
          vol = HP::Cloud::VolumeHelper.new(Connection.instance)
          vol.name = name
          vol.size = size
          vol.description = options[:description]
          vol.meta.set_metadata(options[:metadata])
          if vol.save == true
            display "Created volume '#{name}' with id '#{vol.id}'."
          else
            error(vol.error_string, vol.error_code)
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

module HP
  module Cloud
    class CLI < Thor

      desc "volumes:attach <volume> <server> <device>", "attach a volume to a server with the given device name"
      long_desc <<-DESC
  Attach a volume to a server on the specified device name.

Examples:
  hpcloud volumes:attach myVolume myServer /dev/sdf                         # attach myVolume to myServer on /dev/sdf
  hpcloud volumes:attach my-volume myServer /dev/sdg -z az-2.region-a.geo-1 # Optionally specify an availability zone

      DESC
      method_option :availability_zone,
                    :type => :string, :aliases => '-z',
                    :desc => 'Set the availability zone.'
      define_method "volumes:attach" do |vol_name, server_name, device|
        begin
          Connection.instance.set_options(options)
          server = Servers.new.get(server_name)
          if server.is_valid?
            volume = Volumes.new.get(vol_name)
            if volume.is_valid?
              volume.attach(server, device)
              display "Attached volume '#{volume.name}' to '#{server.name}' on '#{device}'."
            else
              error volume.error_string, volume.error_code
            end
          else
            error server.error_string, server.error_code
          end
        rescue Fog::HP::Errors::ServiceError, Fog::Compute::HP::Error, Excon::Errors::BadRequest, Excon::Errors::InternalServerError => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden, Excon::Errors::Conflict => error
          display_error_message(error, :permission_denied)
        end
      end

    end
  end
end

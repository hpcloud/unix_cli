module HP
  module Cloud
    class CLI < Thor

      map 'volumes:servers' => 'volumes:server'

      desc "volumes:server [server]", "list the volumes on server"
      long_desc <<-DESC
  List the volumes attached to servers with the device they are using.  Optionally, you may filter by specifying server names or ids on the command line.

Examples:
  hpcloud volumes:server                                 # List all the attached volumes
  hpcloud volumes:server myServer                        # List the volumes on myServer
  hpcloud volumes:server myServer -z az-2.region-a.geo-1 # Optionally specify an availability zone

Aliases: volumes:servers
      DESC
      method_option :availability_zone,
                    :type => :string, :aliases => '-z',
                    :desc => 'Set the availability zone.'
      define_method "volumes:server" do |*srv_name_or_ids|
        begin
          @exit_status = nil
          Connection.instance.set_options(options)
          hshes = []
          servers = Servers.new.get(srv_name_or_ids)
          servers.each { |server|
            if server.is_valid? == false
              error_message server.error_string, server.error_code
              next
            end
            ray = VolumeAttachments.new(server).get_hash()
            if ray.nil?
              error_message "Cannot find any volumes for '#{server.name}'.", :not_found
              next
            end
            hshes += ray
          }
          if hshes.empty? == false
            tablelize(hshes, VolumeAttachment.get_keys())
          end
          if @exit_status.nil? == false
            exit @exit_status
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

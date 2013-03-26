module HP
  module Cloud
    class CLI < Thor

      map 'volumes:servers' => 'volumes:server'

      desc "volumes:server [server]", "List the volumes on server."
      long_desc <<-DESC
  List the volumes attached to servers with the device they are using.  Optionally, you may filter by specifying the server name or ID on the command line.

Examples:
  hpcloud volumes:server                                 # List all the attached volumes:
  hpcloud volumes:server myServer                        # List the volumes on server `myServer`:
  hpcloud volumes:server myServer -z az-2.region-a.geo-1 # List the volumes on server `myServer` for availability zone `az-2.region-a.geo-1`:
      DESC
      CLI.add_report_options
      CLI.add_common_options
      define_method "volumes:server" do |*arguments|
        cli_command(options) {
          rayray = []
          servers = Servers.new.get(arguments)
          servers.each { |server|
            if server.is_valid? == false
              @log.error server.cstatus
              next
            end
            ray = VolumeAttachments.new(server).get_array()
            if ray.empty?
              unless arguments.empty?
                @log.error "Cannot find any volumes for '#{server.name}'.", :not_found
              end
              next
            end
            rayray += ray
          }
          if rayray.empty? == false
            Tableizer.new(options, VolumeAttachment.get_keys(), rayray).print
          end
        }
      end
    end
  end
end

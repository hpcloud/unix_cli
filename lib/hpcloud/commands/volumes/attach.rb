module HP
  module Cloud
    class CLI < Thor

      desc "volumes:attach <volume> <server> <device_or_number>", "Attach a volume to a server specified by device name or number."
      long_desc <<-DESC
  Attach a volume to a server on the specified device name.  You may specify a device name in the format /dev/sdX where X is b, c, d, ... or a mount point 1, 2, 3,...  The mount point 1 would map to /dev/sdb on a Linux platform.

Examples:
  hpcloud volumes:attach myVolume myServer /dev/sdf                         # Attach volume `myVolume` to server `myServer` on device `/dev/sdf`:
  hpcloud volumes:attach myVolume myServer 1                                # Attach volume `myVolume` to server `myServer` on device `/dev/sdb`:
  hpcloud volumes:attach my-volume myServer /dev/sdg -z az-2.region-a.geo-1 # Attach volume `my-volume` to server `myServer` on device `/dev/sdf` for availability zone `az-2.region-a.geo-1`:

      DESC
      CLI.add_common_options
      define_method "volumes:attach" do |vol_name, server_name, device|
        cli_command(options) {
          server = Servers.new.get(server_name)
          if server.is_valid?
            volume = Volumes.new.get(vol_name)
            if volume.is_valid?
              if volume.fog.ready?
                device = volume.map_device(device)
                volume.attach(server, device)
                @log.display "Attached volume '#{volume.name}' to '#{server.name}' on '#{device}'."
              else
                @log.fatal "Error attaching volume already in use '#{volume.name}'", :conflicted
              end
            else
              @log.fatal volume.cstatus
            end
          else
            @log.fatal server.cstatus
          end
        }
      end
    end
  end
end

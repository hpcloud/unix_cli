module HP
  module Cloud
    class CLI < Thor

      desc "volumes:attach <volume> <server> <device_or_number>", "Attach a volume to a server specified by device name or number."
      long_desc <<-DESC
  Attach a volume to a server on the specified device name.  You may specify a device name in the format /dev/vdX where X is c, d, e, ... or a attacment point 3, 4, 5,...  The attacment point 1 would map to /dev/vda on a Linux platform, but /dev/vda and /dev/vdb are already in use by the server, so you need to start with 3 or /dev/vdc.  If you attempt to attach a volume to an attachment point that is in use, it will fail silently.  The call is asynchronous and the failure cannot be detected by the CLI.  If you attempt to mount to attachment point 4 and attachment point 3 is not in use, your volume will be attached to attachment point 3 or /dev/vdc on Linux.  This cannot be detected by the CLI.

Examples:
  hpcloud volumes:attach myVolume myServer /dev/vdc                         # Attach volume `myVolume` to server `myServer` on device `/dev/vdc`:
  hpcloud volumes:attach myVolume myServer 4                                # Attach volume `myVolume` to server `myServer` on device `/dev/vdb`:
  hpcloud volumes:attach my-volume myServer /dev/vdg -z az-2.region-a.geo-1 # Attach volume `my-volume` to server `myServer` on device `/dev/vdg` for availability zone `az-2.region-a.geo-1`:

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

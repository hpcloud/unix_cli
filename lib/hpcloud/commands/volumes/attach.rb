# encoding: utf-8
#
# © Copyright 2013 Hewlett-Packard Development Company, L.P.
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

module HP
  module Cloud
    class CLI < Thor

      desc "volumes:attach <volume> <server> <device_or_number>", "Attach a volume to a server specified by device name or number."
      long_desc <<-DESC
  Attach a volume to a server on the specified device name.  You may specify a device name in the format /dev/vdX where X is c, d, e, ... or a attacment point 3, 4, 5,...  The attacment point 1 would map to /dev/vda on a Linux platform, but /dev/vda and /dev/vdb are already in use by the server, so you need to start with 3 or /dev/vdc.  If you attempt to attach a volume to an attachment point that is in use, it will fail silently.  The call is asynchronous and the failure cannot be detected by the CLI.  If you attempt to mount to attachment point 4 and attachment point 3 is not in use, your volume will be attached to attachment point 3 or /dev/vdc on Linux.  This cannot be detected by the CLI.

Examples:
  hpcloud volumes:attach myVolume myServer /dev/vdc                         # Attach volume `myVolume` to server `myServer` on device `/dev/vdc`
  hpcloud volumes:attach f9520651 b8e90a48 4                                # Attach volume `f9520651` to server `b8e90a48` on device `/dev/vdb`

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

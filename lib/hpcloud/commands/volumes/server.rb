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

      map 'volumes:servers' => 'volumes:server'

      desc "volumes:server [server]", "List the volumes on server."
      long_desc <<-DESC
  List the volumes attached to servers with the device they are using.  Optionally, you may filter by specifying the server name or ID on the command line.

Examples:
  hpcloud volumes:server                                 # List all the attached volumes
  hpcloud volumes:server myServer                        # List the volumes on server `myServer`
  hpcloud volumes:server f9520651                        # List the volumes on server `f9520651`
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

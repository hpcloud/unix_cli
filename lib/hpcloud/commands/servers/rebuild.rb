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

      desc "servers:rebuild name_or_id [image_name_or_id]", "Rebuild a server (specified by server name or ID)."
      long_desc <<-DESC
  Rebuild an existing server specified by name or ID. Optionally, you may rebuild the server with a new image.  Rebuilding a server may take some time so it might be necessary to check the status of the server by issuing the command 'hpcloud servers'. Optionally, you can specify an availability zone.

Examples:
  hpcloud servers:rebuild Hal9000    # Rebuild server 'Hal9000'
  hpcloud servers:rebuild 53e78869 c80dfe05   # Rebuild server 53e78869 with image c80dfe05
      DESC
      CLI.add_common_options
      define_method "servers:rebuild" do |name_or_id, *image_name_or_id|
        cli_command(options) {
          server = Servers.new.get(name_or_id, false)
          if server.is_valid?
            image_id = server.image
            unless image_name_or_id.nil?
              unless image_name_or_id.empty?
                image = Images.new.get(image_name_or_id[0], false)
                if image.is_valid?
                  image_id = image.id
                else
                  @log.fatal image.cstatus
                end
              end
            end
            server.fog.rebuild(image_id, server.name)
            @log.display "Server '#{server.name}' being rebuilt."
          else
            @log.fatal server.cstatus
          end
        }
      end
    end
  end
end

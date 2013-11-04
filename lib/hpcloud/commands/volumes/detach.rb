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

require 'csv'

module HP
  module Cloud
    class CLI < Thor

      desc "volumes:detach name_or_id [name_or_id ...]", "Detach a volume or volumes."
      long_desc <<-DESC
  Detach volumes from all servers.  You may specify the volume by name or ID.  You can detach one more more volumes in a command line.

Examples:
  hpcloud volumes:detach myVolume  # Detach the volume 'myVolume'
  hpcloud volumes:detach 3407653b  # Detach the volume with ID 1159

      DESC
      CLI.add_common_options
      define_method "volumes:detach" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          Volumes.new.get(name_or_ids).each { |volume|
            if volume.is_valid?
              if (volume.detach() == true)
                @log.display "Detached volume '#{volume.name}' from '#{volume.servers}'."
              else
                @log.fatal volume.cstatus
              end
            else
              @log.fatal volume.cstatus
            end
          }
        }
      end

    end
  end
end

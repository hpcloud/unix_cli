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

      map %w(volumes:rm volumes:delete volumes:del) => 'volumes:remove'

      desc "volumes:remove name_or_id [name_or_id ...]", "Remove a volume or volumes (specified by name or ID)."
      long_desc <<-DESC
  Remove volumes by specifying their names or ID. You may specify more than one volume name or ID on a command line.  Optionally, you can specify an availability zone.

Examples:
  hpcloud volumes:remove tome treatise   # Delete the volumes 'tome' and 'treatise'
  hpcloud volumes:remove 038d0e77        # Delete the volume with ID 038d0e77

Aliases: volumes:rm, volumes:delete, volumes:del
      DESC
      CLI.add_common_options
      define_method "volumes:remove" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          volumes = Volumes.new.get(name_or_ids, false)
          volumes.each { |volume|
            sub_command("removing volume") {
              if volume.is_valid?
                volume.destroy
                @log.display "Removed volume '#{volume.name}'."
              else
                @log.error volume.cstatus
              end
            }
          }
        }
      end
    end
  end
end

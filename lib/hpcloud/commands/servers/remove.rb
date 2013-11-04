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

      map %w(servers:rm servers:delete servers:del) => 'servers:remove'

      desc "servers:remove name_or_id [name_or_id ...]", "Remove a server or servers (specified by name or ID)."
      long_desc <<-DESC
  Remove existing servers by specifying their name or ID. Optionally, you can specify an availability zone.

Examples:
  hpcloud servers:remove my-server          # Delete 'my-server'
  hpcloud servers:remove DeepThought Blaine # Delete the servers 'DeepThought' and 'Blaine'
  hpcloud servers:remove 53e78869           # Delete the server with the ID 53e78869

Aliases: servers:rm, servers:delete, servers:del
      DESC
      CLI.add_common_options
      define_method "servers:remove" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          servers = Servers.new.get(name_or_ids, false)
          servers.each { |server|
            sub_command("removing server") {
              if server.is_valid?
                server.destroy
                @log.display "Removed server '#{server.name}'."
              else
                @log.error server.cstatus
              end
            }
          }
        }
      end
    end
  end
end

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

      map 'servers:metadata:rm' => 'servers:metadata:remove'

      desc "servers:metadata:remove <name> <metadata_key> ...", "Remove metadata from a server."
      long_desc <<-DESC
  Remove metadata from a server in your compute account.  You can speciry the erver name or ID.  You can specify one or more metadata keys on the command line.  Optionally, you can specify an availability zone.

Examples:
  hpcloud servers:metadata:remove :my_server r2 c3  # Remove the the r2 and c3 metadata from the server
  hpcloud servers:metadata:remove b8e90a48 r2 c3  # Remove the the r2 and c3 metadata from the server

Aliases: servers:metadata:rm
      DESC
      CLI.add_common_options
      define_method "servers:metadata:remove" do |name_or_id, *metadata|
        cli_command(options) {
          server = Servers.new.get(name_or_id)
          if server.is_valid? == false
            @log.fatal server.cstatus
          else
            metadata.each { |key|
              if server.meta.remove_metadata(key)
                @log.display "Removed metadata '#{key}' from server '#{name_or_id}'."
              else
                @log.error server.meta.cstatus
              end
            }
          end
        }
      end
    end
  end
end

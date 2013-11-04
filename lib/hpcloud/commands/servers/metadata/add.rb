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

      map 'servers:metadata:update' => 'servers:metadata:add'

      desc "servers:metadata:add <name_or_id> <metadata>", "Add metadata to a server."
      long_desc <<-DESC
  Add metadata to a server in your compute account.  You can specify the erver name or ID.  Optionally, you can an availability zone. The metadata should be a comma separated list of name value pairs.

Examples:
  hpcloud servers:metadata:add my_server 'r2=d2,c3=po'  # Add the specified metadata to the server (if the metadata exists, it is updated)
  hpcloud servers:metadata:add c14411d7 'chew=bacca,han=solo'  # Add the specified metadata to the server (if the metadata exists, it is updated)

Aliases: servers:metadata:update
      DESC
      CLI.add_common_options
      define_method "servers:metadata:add" do |name_or_id, metadata|
        cli_command(options) {
          server = Servers.new.get(name_or_id.to_s)
          if server.is_valid? == false
            @log.fatal server.cstatus
          else
            if server.meta.set_metadata(metadata)
              @log.display "Server '#{name_or_id}' set metadata '#{metadata}'."
            else
              @log.fatal server.meta.cstatus
            end
          end

        }
      end
    end
  end
end

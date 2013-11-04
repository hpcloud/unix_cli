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

require 'hpcloud/servers'
require 'hpcloud/metadata'

module HP
  module Cloud
    class CLI < Thor

      map 'servers:metadata:list' => 'servers:metadata'

      desc "servers:metadata <name_or_id>", "List the metadata for a server."
      long_desc <<-DESC
  List the metadata for a server in your compute account. You can specify either the name or the ID of the server.  Optionally, you can specify an availability zone.

Examples:
  hpcloud servers:metadata Skynet    # List server metadata
  hpcloud servers:metadata c14411d7  # List server metadata

Aliases: servers:metadata:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      define_method "servers:metadata" do |name_or_id|
        cli_command(options) {
          server = Servers.new.get(name_or_id)
          if server.is_valid?
            ray = server.meta.to_array()
            Tableizer.new(options, Metadata.get_keys(), ray).print
          else
            @log.fatal server.cstatus
          end
        }
      end
    end
  end
end

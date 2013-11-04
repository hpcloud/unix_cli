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

require 'hpcloud/metadata'

module HP
  module Cloud
    class CLI < Thor

      map 'volumes:metadata:list' => 'volumes:metadata'

      desc "volumes:metadata <volume_name_or_id>", "List the metadata for a volume."
      long_desc <<-DESC
  List the metadata for a volume in your compute account. You may specify the volume by either the name or the ID.  Optionally, you can specify an availability zone.

Examples:
  hpcloud volumes:metadata Skynet   # List the metadata for volume 'Skynet'
  hpcloud volumes:metadata d6a89a5d     # List metadata for the volume with the ID d6a89a5d

Aliases: volumes:metadata:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      define_method "volumes:metadata" do |name_or_id|
        cli_command(options) {
          volume = Volumes.new.get(name_or_id)
          if volume.is_valid?
            hsh = volume.meta.to_array()
            Tableizer.new(options, Metadata.get_keys(), hsh).print
          else
            @log.fatal volume.cstatus
          end
        }
      end
    end
  end
end

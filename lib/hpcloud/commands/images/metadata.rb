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

      map 'images:metadata:list' => 'images:metadata'

      desc "images:metadata <image_name_or_id>", "List the metadata for an image."
      long_desc <<-DESC
  List the metadata for an image in your compute account. You may specify either the name or ID of the image.  Optionally, you may specify an availability zone.

Examples:
  hpcloud images:metadata Skynet                        # List the metadata for image 'Skynet'
  hpcloud images:metadata '7ba2a4b6'                        # List the metadata for image '7ba2a4b6'

Aliases: images:metadata:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      define_method "images:metadata" do |name_or_id|
        cli_command(options) {
          image = Images.new.get(name_or_id.to_s)
          if image.is_valid?
            ray = image.meta.to_array()
            Tableizer.new(options, Metadata.get_keys(), ray).print
          else
            @log.fatal image.cstatus
          end
        }
      end

    end
  end
end

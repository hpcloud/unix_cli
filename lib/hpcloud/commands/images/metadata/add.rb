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

      map 'images:metadata:update' => 'images:metadata:add'

      desc "images:metadata:add <name> <metadata>", "Add metadata to an image."
      long_desc <<-DESC
  Add metadata to a image in your compute account.  You may specify the mage name or ID.  If metadata already exists, it is updated.  You must specify the M\metadata as a comma separated list of name value pairs.  Optionally, you may specify an availability zone.

Examples:
  hpcloud images:metadata:add my_image 'r2=d2,c3=po'  # Add the specified metadata to the image (if the metadata exists, it is updated)

Aliases: images:metadata:update
      DESC
      CLI.add_common_options
      define_method "images:metadata:add" do |name_or_id, metadata|
        cli_command(options) {
          image = Images.new.get(name_or_id.to_s)
          if image.is_valid?
            if image.meta.set_metadata(metadata)
              @log.display "Image '#{name_or_id}' set metadata '#{metadata}'."
            else
              @log.fatal image.meta.cstatus
            end
          else
            @log.fatal image.cstatus
          end
        }
      end
    end
  end
end

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

      map %w(images:rm images:delete images:del) => 'images:remove'

      desc "images:remove name_or_id [name_or_id ...]", "Remove images by name or identifier."
      long_desc <<-DESC
  Remove existing images by specifying thier names or IDs. Optionally, you may specify an availability zone.

Examples:
  hpcloud images:remove my-image          # Delete image 'my-image'
  hpcloud images:remove 53e78869 8dbf51b8 # Delete images '53e78869' and '8dbf51b8'

Aliases: images:rm, images:delete, images:del
      DESC
      CLI.add_common_options
      define_method "images:remove" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          images = Images.new.get(name_or_ids, false)
          images.each { |image|
            sub_command("removing image") {
              if image.is_valid?
                image.fog.destroy
                @log.display "Removed image '#{image.name}'."
              else
                @log.error image.cstatus
              end
            }
          }
        }
      end

    end
  end
end

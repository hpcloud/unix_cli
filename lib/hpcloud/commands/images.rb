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

require 'hpcloud/images'
require 'hpcloud/image_helper'
require 'hpcloud/commands/images/add'
require 'hpcloud/commands/images/metadata'
require 'hpcloud/commands/images/remove'
require 'hpcloud/commands/images/metadata/add'
require 'hpcloud/commands/images/metadata/remove'

module HP
  module Cloud
    class CLI < Thor

      map 'images:list' => 'images'

      desc "images [name_or_id ...]", "List the available images in your compute account."
      long_desc <<-DESC
  List the images in your compute account. You may filter the images displayed by specifying one ore more image names or IDs on the command line.  Optionally, you can specify an availability zone.

Examples:
  hpcloud images                         # List the images
  hpcloud images 701be39b                # List image '701be39b'
  hpcloud images -z az-2.region-a.geo-1  # List images for availability zone `az-2.region-a.geo-1`

Aliases: images:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      def images(*arguments)
        cli_command(options) {
          images = Images.new()
          if images.empty?
            @log.display "You currently have no images, use `#{selfname} images:add` to create one."
          else
            ray = images.get_array(arguments)
            if ray.empty?
              @log.display "There are no images that match the provided arguments"
            else
              Tableizer.new(options, ImageHelper.get_keys(), ray).print
            end
          end
        }
      end

    end
  end
end

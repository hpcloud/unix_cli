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

      desc "images [name_or_id ...]", "list of available images"
      long_desc <<-DESC
  List the images in your compute account. You may filter the images displayed by specifying one ore more image names or ids on the command line.  Optionally, an availability zone can be passed.

Examples:
  hpcloud images                         # List images
  hpcloud images 1239                    # List image '1239'
  hpcloud images -z az-2.region-a.geo-1  # List images for an availability zone

Aliases: images:list
      DESC
      CLI.add_common_options
      def images(*arguments)
        cli_command(options) {
          images = Images.new()
          if images.empty?
            display "You currently have no images, use `#{selfname} images:add` to create one."
          else
            hsh = images.get_hash(arguments)
            if hsh.empty?
              display "There are no images that match the provided arguments"
            else
              tablelize(hsh, ImageHelper.get_keys())
            end
          end
        }
      end

    end
  end
end

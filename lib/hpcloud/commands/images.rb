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
  hpcloud images                         # List the images:
  hpcloud images 1239                    # List image '1239':
  hpcloud images -z az-2.region-a.geo-1  # List images for availability zone `az-2.region-a.geo-1`:

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

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

      desc "images", "list of available images"
      long_desc <<-DESC
  List the images in your compute account. Optionally, an availability zone can be passed.

Examples:
  hpcloud images                         # List images
  hpcloud images -z az-2.region-a.geo-1  # List images for an availability zone

Aliases: images:list
      DESC
      CLI.add_common_options()
      def images(*arguments)
        begin
          Connection.instance.set_options(options)
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
        rescue Fog::HP::Errors::ServiceError, Fog::Compute::HP::Error => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
      end

    end
  end
end

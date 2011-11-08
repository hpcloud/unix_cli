require 'hpcloud/commands/images/add'

module HP
  module Cloud
    class CLI < Thor

      map 'images:list' => 'images'

      desc "images", "list of available images"
      long_desc <<-DESC
  List the images in your compute account.

Examples:
  hpcloud images

Aliases: images:list
      DESC
      def images
        begin
          images = connection(:compute).images
          if images.empty?
            display "You currently have no images to use."
          else
            images.table([:id, :architecture, :type, :is_public, :kernel_id, :platform, :name, :state])
          end
        rescue Excon::Errors::Forbidden => error
          display_error_message(error)
        end
      end

    end
  end
end
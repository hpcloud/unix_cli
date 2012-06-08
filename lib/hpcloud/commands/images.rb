require 'hpcloud/commands/images/add'
require 'hpcloud/commands/images/remove'

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
      method_option :availability_zone,
                    :type => :string, :aliases => '-z',
                    :desc => 'Set the availability zone.'
      def images
        begin
          images = connection(:compute, options).images
          if images.empty?
            display "You currently have no images to use."
          else
            images.table([:id, :name, :minDisk, :minRam, :created_at, :updated_at, :status])
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
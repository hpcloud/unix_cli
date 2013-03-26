module HP
  module Cloud
    class CLI < Thor

      map 'images:metadata:rm' => 'images:metadata:remove'

      desc "images:metadata:remove <image_name_or_id> [metadata_key ...]", "Remove metadata from an image."
      long_desc <<-DESC
  Remove metadata from an image in your compute account.  You may specify an image name or ID.  Optionally, you may specify an availability zone.

Examples:
  hpcloud images:metadata:remove my_image r2 c3  # Remove the specified metadata from the image:

Aliases: images:metadata:rm
      DESC
      CLI.add_common_options
      define_method "images:metadata:remove" do |name_or_id, *metadata|
        cli_command(options) {
          image = Images.new.get(name_or_id.to_s)
          if image.is_valid?
            metadata.each { |key|
              if image.meta.remove_metadata(key)
                @log.display "Removed metadata '#{key}' from image '#{name_or_id}'."
              else
                @log.error image.meta.cstatus
              end
            }
          else
            @log.fatal image.cstatus
          end
        }
      end
    end
  end
end

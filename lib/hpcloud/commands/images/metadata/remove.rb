module HP
  module Cloud
    class CLI < Thor

      map 'images:metadata:rm' => 'images:metadata:remove'

      desc "images:metadata:remove <name> <metadata>", "remove metadata from a image"
      long_desc <<-DESC
  Remove metadata from an image in your compute account.  Image name or id may be specified.  Optionally, an availability zone can be passed.

Examples:
  hpcloud images:metadata:remove my_image r2 c3  # Remove the specified metadata from the image.

Aliases: rm
      DESC
      CLI.add_common_options()
      define_method "images:metadata:remove" do |name_or_id, *metadata|
        cli_command(options) {
          image = Images.new.get(name_or_id.to_s)
          if image.is_valid?
            metadata.each { |key|
              if image.meta.remove_metadata(key)
                display "Removed metadata '#{key}' from image '#{name_or_id}'."
              else
                error_message(image.meta.error_string, image.meta.error_code)
              end
            }
          else
            error(image.error_string, image.error_code)
          end
        }
      end
    end
  end
end

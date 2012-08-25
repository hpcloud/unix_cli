module HP
  module Cloud
    class CLI < Thor

      map %w(images:rm images:delete images:del) => 'images:remove'

      desc "images:remove <name>", "remove an image by name"
      long_desc <<-DESC
  Remove an existing image by specifying its name. Optionally, an availability zone can be passed.

Examples:
  hpcloud images:remove my-image                           # delete 'my-image'
  hpcloud images:remove my-image -z az-2.region-a.geo-1    # Optionally specify an availability zone

Aliases: images:rm, images:delete, images:del
      DESC
      CLI.add_common_options()
      define_method "images:remove" do |name, *names|
        cli_command(options) {
          names = [name] + names
          images = Images.new.get(names, false)
          images.each { |image|
            begin
              if image.is_valid?
                image.fog.destroy
                display "Removed image '#{name}'."
              else
                error_message(image.error_string, image.error_code)
              end
            rescue Exception => e
              error_message("Error removing image: " + e.to_s, :general_error)
            end
          }
        }
      end

    end
  end
end

module HP
  module Cloud
    class CLI < Thor

      map %w(images:rm images:delete images:del) => 'images:remove'

      desc "images:remove name_or_id [name_or_id ...]", "remove images by name or id"
      long_desc <<-DESC
  Remove an existing images by specifying thier names or ids. Optionally, an availability zone can be passed.

Examples:
  hpcloud images:remove my-image                           # delete 'my-image'
  hpcloud images:remove 1172 1078                          # delete images '1172' and '1078'
  hpcloud images:remove my-image -z az-2.region-a.geo-1    # Optionally specify an availability zone

Aliases: images:rm, images:delete, images:del
      DESC
      CLI.add_common_options
      define_method "images:remove" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          images = Images.new.get(name_or_ids, false)
          images.each { |image|
            begin
              if image.is_valid?
                image.fog.destroy
                display "Removed image '#{image.name}'."
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

module HP
  module Cloud
    class CLI < Thor

      map 'images:metadata:list' => 'images:metadata'

      desc "images:metadata", "list metadata for image"
      long_desc <<-DESC
  List the metadata for an image in your compute account. You may specify either the name or the id of the image.  Optionally, an availability zone can be passed.

Examples:
  hpcloud images:metadata Skynet                        # List image metadata
  hpcloud images:metadata -z az-2.region-a.geo-1 565394 # List image for an availability zone

Aliases: images:metadata:list
      DESC
      CLI.add_common_options()
      define_method "images:metadata" do |name_or_id|
        cli_command(options) {
          image = Images.new.get(name_or_id.to_s)
          if image.is_valid?
            tablelize(image.meta.to_hash(), Metadata.get_keys())
          else
            error(image.error_string, image.error_code)
          end
        }
      end

    end
  end
end

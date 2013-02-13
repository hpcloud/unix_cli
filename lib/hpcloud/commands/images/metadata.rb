module HP
  module Cloud
    class CLI < Thor

      map 'images:metadata:list' => 'images:metadata'

      desc "images:metadata <image_name_or_id>", "List the metadata for an image."
      long_desc <<-DESC
  List the metadata for an image in your compute account. You may specify either the name or ID of the image.  Optionally, you may specify an availability zone.

Examples:
  hpcloud images:metadata Skynet                        # List the metadata for image 'Skynet':
  hpcloud images:metadata '1151'                        # List the metadata for image '1151':
  hpcloud images:metadata -z az-2.region-a.geo-1 565394 # List the metadata for image `565394` for availability zone `az-2.region-a.geo-1`:

Aliases: images:metadata:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      define_method "images:metadata" do |name_or_id|
        cli_command(options) {
          image = Images.new.get(name_or_id.to_s)
          if image.is_valid?
            ray = image.meta.to_array()
            Tableizer.new(options, Metadata.get_keys(), ray).print
          else
            @log.fatal image.cstatus
          end
        }
      end

    end
  end
end

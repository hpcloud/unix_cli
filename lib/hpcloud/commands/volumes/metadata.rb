require 'hpcloud/metadata'

module HP
  module Cloud
    class CLI < Thor

      map 'volumes:metadata:list' => 'volumes:metadata'

      desc "volumes:metadata <volume_name_or_id>", "List the metadata for a volume."
      long_desc <<-DESC
  List the metadata for a volume in your compute account. You may specify the volume by either the name or the ID.  Optionally, you can specify an availability zone.

Examples:
  hpcloud volumes:metadata Skynet   # List the metadata for volume 'Skynet'
  hpcloud volumes:metadata d6a89a5d     # List metadata for the volume with the ID d6a89a5d

Aliases: volumes:metadata:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      define_method "volumes:metadata" do |name_or_id|
        cli_command(options) {
          volume = Volumes.new.get(name_or_id)
          if volume.is_valid?
            hsh = volume.meta.to_array()
            Tableizer.new(options, Metadata.get_keys(), hsh).print
          else
            @log.fatal volume.cstatus
          end
        }
      end
    end
  end
end

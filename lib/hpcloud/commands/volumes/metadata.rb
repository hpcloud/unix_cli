require 'hpcloud/metadata'

module HP
  module Cloud
    class CLI < Thor

      map 'volumes:metadata:list' => 'volumes:metadata'

      desc "volumes:metadata <volume_name_or_id>", "List the metadata for a volume."
      long_desc <<-DESC
  List the metadata for a volume in your compute account. You may specify either the name or the id of the volume.  Optionally, an availability zone can be passed.

Examples:
  hpcloud volumes:metadata Skynet   # List metadata for volume 'Skynet'
  hpcloud volumes:metadata 2929     # List metadata for volume with id 2929
  hpcloud volumes:metadata -z az-2.region-a.geo-1 565394 # List volume metadata for an availability zone

Aliases: volumes:metadata:list
      DESC
      CLI.add_common_options
      define_method "volumes:metadata" do |name_or_id|
        cli_command(options) {
          volume = Volumes.new.get(name_or_id)
          if volume.is_valid?
            hsh = volume.meta.to_hash()
            Tableizer.new(options, Metadata.get_keys(), hsh).print
          else
            error volume.error_string, volume.error_code
          end
        }
      end
    end
  end
end

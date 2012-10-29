module HP
  module Cloud
    class CLI < Thor

      map 'volumes:metadata:update' => 'volumes:metadata:add'

      desc "volumes:metadata:add <name_or_id> <metadata>", "Add metadata to a volume."
      long_desc <<-DESC
  Add metadata to a volume in your compute account.  You can specify the volume name or ID.  Optionally, you can specify an availability zone. The metadata must be a comma separated list of name value pairs.

Examples:
  hpcloud volumes:metadata:add my_volume 'r2=d2,c3=po'  # Add the specified metadata to the volume (f the metadata exists, it is updated):

Aliases: volumes:metadata:update
      DESC
      CLI.add_common_options
      define_method "volumes:metadata:add" do |name_or_id, metadata|
        cli_command(options) {
          volume = Volumes.new.get(name_or_id.to_s)
          if volume.is_valid? == false
            error volume.error_string, volume.error_code
          else
            if volume.meta.set_metadata(metadata)
              display "Volume '#{name_or_id}' set metadata '#{metadata}'."
            else
              error(volume.meta.error_string, volume.meta.error_code)
            end
          end
        }
      end
    end
  end
end

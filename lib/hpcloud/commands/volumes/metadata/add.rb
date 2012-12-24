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
            @log.fatal volume.cstatus
          else
            if volume.meta.set_metadata(metadata)
              @log.display "Volume '#{name_or_id}' set metadata '#{metadata}'."
            else
              @log.fatal volume.meta.cstatus
            end
          end
        }
      end
    end
  end
end

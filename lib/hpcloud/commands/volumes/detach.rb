require 'csv'

module HP
  module Cloud
    class CLI < Thor

      desc "volumes:detach name_or_id [name_or_id ...]", "detach volumes"
      long_desc <<-DESC
  Detach volumes from all servers.  The name or id of the volume to detach may bbe specified.  One more more volumes can be detached in a command line.

Examples:
  hpcloud volumes:detach myVolume     # detach volume 'myVolume'
  hpcloud volumes:detach 1159         # detach volume with id 1159
  hpcloud volumes:detach myVolume -z az-2.region-a.geo-1 # Optionally specify an availability zone

      DESC
      CLI.add_common_options
      define_method "volumes:detach" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          Volumes.new.get(name_or_ids).each { |volume|
            if volume.is_valid?
              if (volume.detach() == true)
                display "Detached volume '#{volume.name}' from '#{volume.servers}'."
              else
                error volume.error_string, volume.error_code
              end
            else
              error volume.error_string, volume.error_code
            end
          }
        }
      end

    end
  end
end

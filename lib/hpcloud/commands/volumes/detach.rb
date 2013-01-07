require 'csv'

module HP
  module Cloud
    class CLI < Thor

      desc "volumes:detach name_or_id [name_or_id ...]", "Detach a volume or volumes."
      long_desc <<-DESC
  Detach volumes from all servers.  You may specify the volume by name or ID.  You can detach one more more volumes in a command line.

Examples:
  hpcloud volumes:detach myVolume     # Detach the volume 'myVolume':
  hpcloud volumes:detach 1159         # Detach the volume with ID 1159:
  hpcloud volumes:detach myVolume -z az-2.region-a.geo-1 # Detach the volume 'myVolume' for availability zone `az-2.region-a.geo-1`:

      DESC
      CLI.add_common_options
      define_method "volumes:detach" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          Volumes.new.get(name_or_ids).each { |volume|
            if volume.is_valid?
              if (volume.detach() == true)
                @log.display "Detached volume '#{volume.name}' from '#{volume.servers}'."
              else
                @log.fatal volume.cstatus
              end
            else
              @log.fatal volume.cstatus
            end
          }
        }
      end

    end
  end
end

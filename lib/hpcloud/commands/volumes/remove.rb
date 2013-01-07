module HP
  module Cloud
    class CLI < Thor

      map %w(volumes:rm volumes:delete volumes:del) => 'volumes:remove'

      desc "volumes:remove name_or_id [name_or_id ...]", "Remove a volume or volumes (specified by name or ID)."
      long_desc <<-DESC
  Remove volumes by specifying their names or ID. You may specify more than one volume name or ID on a command line.  Optionally, you can specify an availability zone.

Examples:
  hpcloud volumes:remove tome treatise   # Delete the volumes 'tome' and 'treatise':
  hpcloud volumes:remove 998             # Delete the volume with ID 998:
  hpcloud volumes:remove my-volume -z az-2.region-a.geo-1  # Delete the volume `my-volume` for availability zone `az-2.region-a.geo-1`:

Aliases: volumes:rm, volumes:delete, volumes:del
      DESC
      CLI.add_common_options
      define_method "volumes:remove" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          volumes = Volumes.new.get(name_or_ids, false)
          volumes.each { |volume|
            sub_command("removing volume") {
              if volume.is_valid?
                volume.destroy
                @log.display "Removed volume '#{volume.name}'."
              else
                @log.error volume.cstatus
              end
            }
          }
        }
      end
    end
  end
end

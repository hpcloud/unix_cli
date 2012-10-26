module HP
  module Cloud
    class CLI < Thor

      map %w(volumes:rm volumes:delete volumes:del) => 'volumes:remove'

      desc "volumes:remove name_or_id [name_or_id ...]", "Remove a volume or volumes (specified by name or ID)."
      long_desc <<-DESC
  Remove volumes by specifying their names or ids. More than one volume name or id may be specified on a command line.  Optionally, an availability zone may be passed.

Examples:
  hpcloud volumes:remove tome treatise   # delete volumes 'tome' and 'treatise'
  hpcloud volumes:remove 998             # delete volume with id 998
  hpcloud volumes:remove my-volume -z az-2.region-a.geo-1  # Optionally specify an availability zone

Aliases: volumes:rm, volumes:delete, volumes:del
      DESC
      CLI.add_common_options
      define_method "volumes:remove" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          volumes = Volumes.new.get(name_or_ids, false)
          volumes.each { |volume|
            begin
              if volume.is_valid?
                volume.destroy
                display "Removed volume '#{volume.name}'."
              else
                error_message(volume.error_string, volume.error_code)
              end
            rescue Exception => e
              error_message("Error removing volume: " + e.to_s, :general_error)
            end
          }
        }
      end
    end
  end
end

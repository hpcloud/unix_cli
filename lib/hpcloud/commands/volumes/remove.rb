module HP
  module Cloud
    class CLI < Thor

      map %w(volumes:rm volumes:delete volumes:del) => 'volumes:remove'

      desc "volumes:remove <id|name> ...", "remove a volume by id or name"
      long_desc <<-DESC
  Remove volumes by specifying their names or ids. Optionally, an availability zone may be passed.

Examples:
  hpcloud volumes:remove my-volume 998                     # delete 'my-volume' and 998
  hpcloud volumes:remove my-volume -z az-2.region-a.geo-1  # Optionally specify an availability zone

Aliases: volumes:rm, volumes:delete, volumes:del
      DESC
      CLI.add_common_options()
      define_method "volumes:remove" do |name, *names|
        cli_command(options) {
          names = [name] + names
          volumes = Volumes.new.get(names, false)
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

require 'csv'

module HP
  module Cloud
    class CLI < Thor

      desc "volumes:detach <volume>", "detach a volume"
      long_desc <<-DESC
  Detach a volume from all servers.

Examples:
  hpcloud volumes:detach myVolume                        # detach myVolume
  hpcloud volumes:detach myVolume -z az-2.region-a.geo-1 # Optionally specify an availability zone

      DESC
      CLI.add_common_options()
      define_method "volumes:detach" do |*vol_names|
        cli_command(options) {
          Volumes.new.get(vol_names).each { |volume|
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

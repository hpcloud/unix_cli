module HP
  module Cloud
    class CLI < Thor

      desc "servers:rebuild name_or_id [image_name_or_id]", "Rebuild a server (specified by server name or ID)."
      long_desc <<-DESC
  Rebuild an existing server specified by name or ID. Optionally, you may rebuild the server with a new image.  Rebuilding a server may take some time so it might be necessary to check the status of the server by issuing the command 'hpcloud servers'. Optionally, you can specify an availability zone.

Examples:
  hpcloud servers:rebuild Hal9000    # Rebuild server 'Hal9000':
  hpcloud servers:rebuild 1003 222   # Rebuild server 1003 with image 222:
  hpcloud servers:rebuild DeepThought -z az-2.region-a.geo-1    # Rebuild server `DeepThought` for availability zone `az-2.region-a.geo-1`:
      DESC
      CLI.add_common_options
      define_method "servers:rebuild" do |name_or_id, *image_name_or_id|
        cli_command(options) {
          server = Servers.new.get(name_or_id, false)
          if server.is_valid?
            image_id = server.image
            unless image_name_or_id.nil?
              unless image_name_or_id.empty?
                image = Images.new.get(image_name_or_id[0], false)
                if image.is_valid?
                  image_id = image.id
                else
                  @log.fatal image.cstatus
                end
              end
            end
            server.fog.rebuild(image_id, nil)
            @log.display "Server '#{server.name}' being rebuilt."
          else
            @log.fatal server.cstatus
          end
        }
      end
    end
  end
end

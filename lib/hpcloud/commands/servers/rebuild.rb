module HP
  module Cloud
    class CLI < Thor

      desc "servers:rebuild name_or_id [image_name_or_id]", "rebuild server specified by server name or id with optional new image"
      long_desc <<-DESC
  Rebuild an existing server specified name or id. Optionally, the server may be rebuilt with a new image.  Rebuilding a server may take some time so it might be necessary to check the status of the server by issuing command, 'hpcloud servers'. Optionally, an availability zone can be passed.

Examples:
  hpcloud servers:rebuild Hal9000    # rebuild 'Hal9000'
  hpcloud servers:rebuild 1003 222   # rebuild server 1003 with image 222
  hpcloud servers:rebuild DeepThought -z az-2.region-a.geo-1    # Optionally specify an availability zone
      DESC
      CLI.add_common_options
      define_method "servers:rebuild" do |name_or_id, image_name_or_id=nil|
        cli_command(options) {
          server = Servers.new.get(name_or_id, false)
          if server.is_valid?
            image_id = server.image
            unless image_name_or_id.nil?
              image = Images.new.get(image_name_or_id, false)
              if image.is_valid?
                image_id = image.id
              else
                error image.error_string, image.error_code
              end
            end
            server.fog.rebuild(image_id, nil)
            display "Server '#{server.name}' being rebuilt."
          else
            error server.error_string, server.error_code
          end
        }
      end
    end
  end
end

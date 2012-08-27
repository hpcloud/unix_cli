module HP
  module Cloud
    class CLI < Thor
    
      map 'loc' => 'location'
    
      desc 'location <object/container>', 'display the URI for a given resource'
      long_desc <<-DESC
  Print the URI of the specified object or container. Optionally, an availability zone can be passed.

Examples: 
  hpcloud location :my_container/file.txt
  hpcloud location :my_container
  hpcloud location :my_container/file.txt -z region-a.geo-1  # Optionally specify an availability zone

Aliases: loc
      DESC
      CLI.add_common_options
      def location(resource)
        cli_command(options) {
          container, key = Container.parse_resource(resource)
          storage_connection = connection(:storage, options)
          if container and key
            dir = storage_connection.directories.get(container)
            if dir
              file = dir.files.get(key)
              if file
                display "#{file.public_url}"
              else
                error "No object exists at '#{container}/#{key}'.", :not_found
              end
            else
              error "No object exists at '#{container}/#{key}'.", :not_found
            end
          elsif container
            dir = storage_connection.directories.get(container)
            if dir
              display "#{dir.public_url}"
            else
              error "No container named '#{container}' exists.", :not_found
            end
          else
            error "Invalid format, see `help location`.", :incorrect_usage
          end
        }
      end
    end
  end
end

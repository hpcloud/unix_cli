module HP
  module Cloud
    class CLI < Thor
    
      map 'loc' => 'location'
    
      desc 'location <object/container> ...', 'Display the URIs for the specified resources.'
      long_desc <<-DESC
  Display the URI of the specified object or container. Optionally, you can specify an availability zone.

Examples:
  hpcloud location :my_container/file.txt  # Display the URI for the file `file.txt` that resides in container `my_container`:
  hpcloud location :my_container  #  Display the URI for all objects in container `my_container`:
  hpcloud location :my_container/file.txt :my_container/other.txt # Display the URIs for the objects `file.txt` and `other.txt` that reside in container `my_container`:
  hpcloud location :my_container/file.txt -z region-a.geo-1  # Display the URI for the file `file.txt` that resides in container `my_container` in availability zone `region-a.geo-1`:

Aliases: loc
      DESC
      CLI.add_common_options
      def location(name, *names)
        cli_command(options) {
          names = [name] + names
          names.each { |name|
            resource = ResourceFactory.create(Connection.instance.storage, name)
            if resource.head
              @log.display resource.public_url
            else
              @log.error resource.cstatus
            end
          }
        }
      end
    end
  end
end

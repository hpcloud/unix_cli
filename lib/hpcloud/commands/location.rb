module HP
  module Cloud
    class CLI < Thor
    
      map 'loc' => 'location'
    
      desc 'location <object/container> ...', 'display the URIs for given resources'
      long_desc <<-DESC
  Print the URI of the specified object or container. Optionally, an availability zone can be passed.

Examples: 
  hpcloud location :my_container/file.txt
  hpcloud location :my_container
  hpcloud location :my_container/file.txt :my_container/other.txt # multiple files or containers
  hpcloud location :my_container/file.txt -z region-a.geo-1  # Optionally specify an availability zone

Aliases: loc
      DESC
      CLI.add_common_options
      def location(name, *names)
        cli_command(options) {
          names = [name] + names
          names.each { |name|
            resource = Resource.create(Connection.instance.storage, name)
            if resource.read_header
              display resource.public_url
            else
              error_message resource.error_string, resource.error_code
            end
          }
        }
      end
    end
  end
end

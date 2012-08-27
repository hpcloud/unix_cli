module HP
  module Cloud
    class CLI < Thor

      map %w(fetch) => 'get'

      desc 'get <object>', 'fetch an object to your local directory'
      long_desc <<-DESC
  Copy an object from a container to your current directory. Optionally, an availability zone can be passed.

Examples: 
  hpcloud get :my_container/file.txt
  hpcloud get :my_container/file.txt -z region-a.geo-1   # Optionally specify an availability zone

Aliases: fetch
      DESC
      CLI.add_common_options()
      def get(resource)
        cli_command(options) {
          container, path = Container.parse_resource(resource)
          type = Resource.detect_type(resource)

          if :object == type
            copy(resource, File.basename(path))
          elsif :container == type
            error "You can get files, but not containers."
          else
            error "The object path '#{resource}' wasn't recognized. Usage: '#{selfname} get :container_name/object_name'.", :incorrect_usage
          end
        }
      end
    end
  end
end


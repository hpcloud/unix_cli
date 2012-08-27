module HP
  module Cloud
    class CLI < Thor
    
      map 'ls' => 'list'
    
      desc 'list <container>', "list container contents"
      long_desc <<-DESC
  List the contents of a specified container. Optionally, an availability zone can be passed.

Examples:
  hpcloud list :my_container                    # List files in container 'my_container'
  hpcloud list                                  # List all containers
  hpcloud list :my_container -z region-a.geo-1  # Optionally specify an availability zone

Aliases: ls

Note: Listing details on files will be available in a future release.
      DESC
      CLI.add_common_options
      def list(name='')
        cli_command(options) {
          return containers if name.empty?
          name = Container.container_name_for_service(name)
          directory = connection(:storage, options).directories.get(name)
          if directory
            directory.files.each { |file| display file.key }
          else
            error "You don't have a container named '#{name}'", :not_found
          end
        }
      end
    end
  end
end

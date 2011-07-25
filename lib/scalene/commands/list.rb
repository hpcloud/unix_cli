module HP
  module Scalene
    class CLI < Thor
    
      map 'ls' => 'list'
    
      desc 'list <container>', "list container contents"
      long_desc <<-DESC
  List the contents of a specified container.

Examples:
  scalene list :my_container  # list files in container 'my_container'
  scalene list             # list all containers

Aliases: ls

Note: Listing details on files will be available in a future release.
      DESC
      def list(name='')
        return containers if name.empty?
        name = Container.container_name_for_service(name)
        begin
          directory = connection.directories.get(name)
          if directory
            directory.files.each { |file| display file.key }
          else
            error "You don't have a container named '#{name}'", :not_found
          end
        rescue Excon::Errors::Forbidden => error
          display_error_message(error)
        end
      end
    
    end
  end
end
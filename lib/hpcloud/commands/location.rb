module HP
  module Cloud
    class CLI < Thor
    
      map 'loc' => 'location'
    
      desc 'location <object/container>', 'display the URI for a given resource'
      long_desc <<-DESC
  Print the URI of the specified object or container.

Examples: 
  hpcloud location :my_container/file.txt
  hpcloud location :my_container

Aliases: loc
      DESC
      def location(resource)
        container, key = Container.parse_resource(resource)
        config = Config.current_credentials
        
        begin
          if container and key
            begin
              if connection.head_object(container, key)
                display "http://#{config[:auth_uri]}/#{container}/#{key}"
              end
            rescue Excon::Errors::NotFound => error
              error "No object exists at '#{container}/#{key}'.", :not_found
            end
        
          elsif container
            begin
              if connection.head_container(container)
                display "http://#{config[:auth_uri]}/#{container}/"
              end
            rescue Excon::Errors::NotFound => error
              error "No container named '#{container}' exists.", :not_found
            end
        
          else
            error "Invalid format, see `help location`.", :incorrect_usage
          end
        rescue Excon::Errors::Forbidden => error
          error 'Access Denied.', :permission_denied
        end
      end
    
    end
  end
end
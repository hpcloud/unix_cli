module HP
  module Cloud
    class Container
    
      # parse a container resource into container name and object key
      def self.parse_resource(resource)
        container, *rest = resource.split('/')
        #raise "No container resource in '#{resource}'." if container[0] != ':'
        container = container[1..-1] if container[0,1] == ':'
        path = rest.empty? ? nil : rest.join('/')
        path << '/' if resource[-1,1] == '/'
        return container, path
      end
    
      # provide an absolute path for use as a storage key
      def self.storage_destination_path(destination_path, current_location)
        if destination_path.to_s.empty?
          File.basename(current_location)
        elsif destination_path[-1,1] == '/'
          destination_path + File.basename(current_location)
        else
          destination_path
        end
      end
    
      def self.container_name_for_service(container_string)
        if container_string[0,1] == ':'
          container_string[1..-1]
        else
          container_string
        end
      end
    
      def self.container_name_for_display(container_string)
      end
    
      # is container_name a valid virtualhost name?
      def self.valid_virtualhost?(container_name)
        if (1..63).include?(container_name.length)
          if container_name =~ /^[a-z0-9-]*$/
            if container_name[0,1] != '-' and container_name[-1,1] != '-'
              return true 
            end
          end
        end
        false
      end
    
    end
  end
end
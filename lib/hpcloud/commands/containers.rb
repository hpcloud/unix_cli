require 'hpcloud/commands/containers/add'
require 'hpcloud/commands/containers/remove'

module HP
  module Cloud
    class CLI < Thor
    
      map 'containers:list' => 'containers'
    
      desc "containers", "list available containers"
      long_desc <<-DESC
  List the containers in your storage account. Optionally, an availability zone can be passed.
  
Examples:
  hpcloud containers                    # List containers
  hpcloud containers -z region-a.geo-1  # Optionally specify an availability zone

Aliases: containers:list
      DESC
      GOPTS.each { |k,v| method_option(k, v) }
      def containers
        begin
          containers = connection(:storage, options).directories
          if containers.empty?
            display "You currently have no containers, use `#{selfname} containers:add <name>` to create one."
          else
            containers.each { |container| display container.key }
          end
        rescue Fog::HP::Errors::ServiceError, Fog::Compute::HP::Error => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        rescue Excon::Errors::Conflict, Excon::Errors::NotFound => error
          display_error_message(error, :not_found)
        end
      end
    
    end
  end
end

require 'scalene/commands/containers/add'
require 'scalene/commands/containers/remove'

module HP
  module Scalene
    class CLI < Thor
    
      map 'containers:list' => 'containers'
    
      desc "containers", "list available containers"
      long_desc <<-DESC
  List the containers in your storage account.
  
Examples:
  scalene containers

Aliases: containers:list
      DESC
      def containers
        begin
          containers = connection.directories
          if containers.empty?
            display "You currently have no containers, use `#{selfname} containers:add <name>` to create one."
          else
            containers.each { |container| display container.key }
          end
        rescue Excon::Errors::Forbidden => error
          display_error_message(error)
        end
      end
    
    end
  end
end
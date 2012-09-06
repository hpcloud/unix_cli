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
      CLI.add_common_options
      def containers
        cli_command(options) {
          containers = connection(:storage, options).directories
          if containers.empty?
            display "You currently have no containers, use `#{selfname} containers:add <name>` to create one."
          else
            containers.each { |container| display container.key }
          end
        }
      end
    end
  end
end

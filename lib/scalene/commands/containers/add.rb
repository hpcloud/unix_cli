module HP
  module Scalene
    class CLI < Thor
    
      desc "containers:add <name>", "add a container"
      long_desc <<-DESC
  Add a new container to your storage account. Container name can be specified with
  or without the preceding colon: 'my_container' or ':my_container'.

Examples:
  scalene container:add :my_container  # Creates a new container called 'my_container'

Aliases: none
      DESC
      method_option :force, :default => false, :type => :boolean, :aliases => '-f', :desc => "Don't prompt if container name is not valid virtual host."
      define_method "containers:add" do |name|
        begin
          name = Container.container_name_for_service(name)
          if acceptable_name?(name, options)
            connection.directories.create(:key => name)
            display "Created container '#{name}'."
          end
        rescue Excon::Errors::Conflict => error
          display_error_message(error, :permission_denied)
        rescue Fog::HP::Storage::NotFound => error
          error 'The container name specified is invalid. Please see API documentation for valid naming guidelines.', :permission_denied
        end 
      end
      
      private
      
      def acceptable_name?(name, options)
        Container.valid_virtualhost?(name) or options[:force] or yes?('Specified container name is not a valid virtualhost, continue anyway?')
      end
    
    end
  end
end
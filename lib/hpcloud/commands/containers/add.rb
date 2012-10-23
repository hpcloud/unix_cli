module HP
  module Cloud
    class CLI < Thor
    
      desc "containers:add name [name ...]", "Add a container."
      long_desc <<-DESC
  Add a new container to your storage account. You may creeate multiple containers by specifying more than one container name on the command line.  Container name can be specified with or without the preceding colon: 'my_container' or ':my_container'. Optionally, an availability zone can be passed.

Examples:
  hpcloud containers:add :my_container                    # Creates a new container called 'my_container'
  hpcloud containers:add :con :tainer                     # Create two new containers called 'con' and 'tainer'
  hpcloud containers:add :my_container -z region-a.geo-1  # Optionally specify an availability zone
      DESC
      method_option :force, :default => false,
                    :type => :boolean, :aliases => '-f',
                    :desc => "Don't prompt if container name is not a valid virtual host."
      CLI.add_common_options
      define_method "containers:add" do |name, *names|
        cli_command(options) {
          names = [name] + names
          names.each { |name|
            begin
              name = Container.container_name_for_service(name)
              if connection(:storage, options).directories.get(name)
                error "Container '#{name}' already exists.", :conflicted
              else
                if acceptable_name?(name, options)
                  connection(:storage, options).directories.create(:key => name)
                  display "Created container '#{name}'."
                end
              end
            rescue Fog::Storage::HP::NotFound => error
              error 'The container name specified is invalid. Please see API documentation for valid naming guidelines.', :permission_denied
            end
          }
        }
      end
      
      private
      
      def acceptable_name?(name, options)
        Container.valid_virtualhost?(name) or options[:force] or yes?('Specified container name is not a valid virtualhost, continue anyway? [y/n]')
      end
    
    end
  end
end

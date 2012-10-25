module HP
  module Cloud
    class CLI < Thor
    
      map %w(containers:rm containers:delete containers:del) => 'containers:remove'
    
      desc "containers:remove <name>", "Remove a container."
      long_desc <<-DESC
  Remove a container. By default this command removes a container if it empty. The `--force` flag allows you to delete non-empty containers.  Be careful with this flag or you could have a really bad day.  Optionally, you can specify an availability zone.

Examples:
  hpcloud containers:remove :my_container                     # Delete 'my_container' if empty
  hpcloud containers:remove :my_container --force             # Delete regardless of contents
  hpcloud containers:remove :my_container -z region-a.geo-1   # Delete the container `my_container` for availability zone

Aliases: containers:rm, containers:delete, containers:del
      DESC
      method_option :force, :default => false,
                    :type => :boolean, :aliases => '-f',
                    :desc => 'Force removal of non-empty containers.'
      CLI.add_common_options
      define_method "containers:remove" do |name|
        cli_command(options) {
          name = Container.container_name_for_service(name)
          begin
            container = connection(:storage, options).directories.head(name)
            if container
              if options.force?
                container.files.each { |file| file.destroy }
              end
              container.destroy
              display "Removed container '#{name}'."
            else
              error "You don't have a container named '#{name}'.", :not_found
            end
          rescue Excon::Errors::Conflict
            error "The container '#{name}' is not empty. Please use -f option to force deleting a container with objects in it.", :general_error
          end
        }
      end
    end
  end
end

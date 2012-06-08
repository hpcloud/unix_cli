module HP
  module Cloud
    class CLI < Thor
    
      map %w(containers:rm containers:delete containers:del) => 'containers:remove'
    
      desc "containers:remove <name>", "remove a container"
      long_desc <<-DESC
  Remove a container. By default this command will only remove a container if it
  empty. The --force flag will allow you to delete non-empty containers.
  Be careful with this flag or you could have a really bad day.
  Optionally, an availability zone can be passed.

Examples:
  hpcloud containers:remove :my_container                     # delete 'my_container' if empty
  hpcloud containers:remove :my_container --force             # delete regardless of contents
  hpcloud containers:remove :my_container -z region-a.geo-1   # Optionally specify an availability zone

Aliases: containers:rm, containers:delete, containers:del
      DESC
      method_option :force, :default => false,
                    :type => :boolean, :aliases => '-f',
                    :desc => 'Force removal of non-empty containers.'
      method_option :availability_zone,
                    :type => :string, :aliases => '-z',
                    :desc => 'Set the availability zone.'
      define_method "containers:remove" do |name|
        name = Container.container_name_for_service(name)
        begin
          container = connection(:storage, options).directories.get(name)
          if container
            if options.force?
              container.files.each { |file| file.destroy }
            end
            container.destroy
            display "Removed container '#{name}'."
          else
            error "You don't have a container named '#{name}'.", :not_found
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
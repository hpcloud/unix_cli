module HP
  module Cloud
    class CLI < Thor
    
      map %w(containers:rm containers:delete containers:del) => 'containers:remove'
    
      desc "containers:remove <name>", "remove a container"
      long_desc <<-DESC
  Remove a container. By default this command will only remove a container if it
  empty. The --force flag will allow you to delete non-empty containers.
  Be careful with this flag or you could have a really bad day.

Examples:
  hpcloud container:remove :my_container          # delete 'my_container' if empty
  hpcloud container:remove :my_container --force  # delete regardless of contents

Aliases: containers:rm, containers:delete, containers:del
      DESC
      method_option :force, :default => false, :type => :boolean, :aliases => '-f', :desc => 'Force removal of non-empty container'
      define_method "containers:remove" do |name|
        name = Container.container_name_for_service(name)
        begin
          container = connection.directories.get(name)
        rescue Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
        if container
          if options.force?
            container.files.each { |file| file.destroy }
          end
          begin
            container.destroy
            display "Removed container '#{name}'."
          rescue Excon::Errors::Conflict, Excon::Errors::Forbidden => error
            display_error_message(error)
          end
        else
          error "You don't have a container named '#{name}'.", :not_found
        end
      end
    
    end
  end
end
module HP
  module Cloud
    class CLI < Thor

      map %w(rm delete destroy del) => 'remove'

      desc 'remove <object/container>', 'remove an object or container'
      long_desc <<-DESC
  Remove an object. If the specified target is a container, behavior is
  identical to calling `containers:remove`. Optionally, an availability zone can be passed.
        
Examples:
  hpcloud remove :my_container/my_file.txt        # Delete object 'my_file.txt'
  hpcloud remove :my_container                    # Delete container 'my_container'
  hpcloud remove :my_container -z region-a.geo-1  # Optionally specify an availability zone

Aliases: rm, delete, destroy, del
      DESC
      method_option :force, :default => false,
                    :type => :boolean, :aliases => '-f',
                    :desc => 'Do not confirm removal, remove non-empty containers.'
      CLI.add_common_options()
      def remove(resource)
        cli_command(options) {
          container, path = Container.parse_resource(resource)
          type = Resource.detect_type(resource)

          begin
            directory = connection(:storage, options).directories.head(container)
          rescue Excon::Errors::Forbidden => error
            error "Access Denied.", :permission_denied
          end
          if not directory
            error "You don't have a container named '#{container}'", :not_found
          end
  
          if type == :object
            begin
              # use head instead of get for performance
              file = directory.files.head(path)
            rescue Excon::Errors::Forbidden => error
              display_error_message(error)
            end
            if file
              file.destroy
              display "Removed object '#{resource}'."
            else
              error "You don't have a object named '#{path}'.", :not_found
            end
          elsif type == :container
            if options.force? or yes?("Are you sure you want to remove the container '#{container}'?")
              send('containers:remove', container)
            end
          else
            error "Could not find resource '#{resource}'. Correct syntax is :containername/objectname.", :incorrect_usage
          end
        }
      end
    end
  end
end


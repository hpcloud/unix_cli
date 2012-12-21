module HP
  module Cloud
    class CLI < Thor

      map %w(rm delete destroy del) => 'remove'

      desc 'remove object_or_container [object_or_container ...]', 'Remove objects or containers.'
      long_desc <<-DESC
  Remove objects or containers. Optionally, you can specify an availability zone.
        
Examples:
  hpcloud remove :tainer/my.txt :tainer/other.txt # Delete objects 'my.txt' and 'other.txt' from container `tainer`:
  hpcloud remove :my_container                    # Delete container 'my_container':
  hpcloud remove :my_container -z region-a.geo-1  # Delete container 'my_container' in availability zone `region-a.geo-1`:

Aliases: rm, delete, destroy, del
      DESC
      method_option :force, :default => false,
                    :type => :boolean, :aliases => '-f',
                    :desc => 'Do not confirm removal, remove non-empty containers.'
      CLI.add_common_options
      def remove(name, *names)
        cli_command(options) {
          names = [name] + names
          names.each { |name|
            resource = ResourceFactory.create(Connection.instance.storage, name)
            forceit = options.force
            if resource.is_container?
              unless options.force?
                unless yes?("Are you sure you want to remove the container '#{name}'?")
                  @log.display "Container '#{name}' not removed."
                  next
                end
                forceit = true
              end
            end
            if resource.remove(forceit)
              @log.display "Removed '#{name}'."
            else
              @log.error resource.error_string, resource.error_code
            end
          }
        }
      end
    end
  end
end


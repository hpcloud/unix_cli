module HP
  module Cloud
    class CLI < Thor

      map %w(rm delete destroy del) => 'remove'

      desc 'remove object_or_container [object_or_container ...]', 'Remove objects or containers.'
      long_desc <<-DESC
  Remove objects or containers. Optionally, an availability zone can be passed.
        
Examples:
  hpcloud remove :tainer/my.txt :tainer/other.txt # Delete object 'my.txt' and 'other.txt'
  hpcloud remove :my_container                    # Delete container 'my_container'
  hpcloud remove :my_container -z region-a.geo-1  # Optionally specify an availability zone

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
            resource = Resource.create(Connection.instance.storage, name)
            if resource.is_container?
              unless options.force?
                unless yes?("Are you sure you want to remove the container '#{name}'?")
                  display "Container '#{name}' not removed."
                  next
                end
              end
            end
            if resource.remove(options.force)
              display "Removed '#{name}'."
            else
              error_message resource.error_string, resource.error_code
            end
          }
        }
      end
    end
  end
end


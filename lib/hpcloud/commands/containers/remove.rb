module HP
  module Cloud
    class CLI < Thor
    
      map %w(containers:rm containers:delete containers:del) => 'containers:remove'
    
      desc "containers:remove name [name ...]", "Remove a containers."
      long_desc <<-DESC
  Remove a container. By default this command removes a container if it empty. The `--force` flag deletes non-empty containers.  Be careful with this flag or you could have a really bad day.  Optionally, you can specify an availability zone.

Examples:
  hpcloud containers:remove :my_container                     # Delete 'my_container' (if empty):
  hpcloud containers:remove :my_container --force             # Delete `my container` (regardless of contents):
  hpcloud containers:remove :my_container -z region-a.geo-1   # Delete the container `my_container` for availability zone 'region-a.geo-1`:

Aliases: containers:rm, containers:delete, containers:del
      DESC
      method_option :force, :default => false,
                    :type => :boolean, :aliases => '-f',
                    :desc => 'Force removal of non-empty containers.'
      CLI.add_common_options
      define_method "containers:remove" do |name, *names|
        cli_command(options) {
          names = [name] + names
          names.each { |name|
            resource = Resource.create_remote(Connection.instance.storage, name)
            if resource.is_container?
              if resource.remove(options.force)
                display "Removed container '#{name}'."
              else
                error_message resource.error_string, resource.error_code
              end
            else
              error_message "The specified object is not a container: #{name}", :incorrect_usage
            end
          }
        }
      end
    end
  end
end

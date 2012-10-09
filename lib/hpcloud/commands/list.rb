module HP
  module Cloud
    class CLI < Thor
    
      map %w(ls containers containers:list) => 'list'
      map 'ls' => 'list'
    
      desc 'list <container>', "list container contents"
      long_desc <<-DESC
  List the contents of a specified container. Optionally, an availability zone can be passed.

Listing details on files will be available in a future release.


Examples:
  hpcloud list :tainer/1.txt :tainer/2.txt      # List the two objects
  hpcloud list :tainer                          # List the all the objects in the container
  hpcloud list                                  # List all containers
  hpcloud list :my_container -z region-a.geo-1  # Optionally specify an availability zone

Aliases: ls
      DESC
      CLI.add_common_options
      def list(*sources)
        cli_command(options) {
          sources = [""] if sources.empty?
          sources.each { |name|
            begin
              from = Resource.create(Connection.instance.storage, name)
              if from.valid_source()
                found = false
                from.foreach { |file|
                  display file.fname
                  found = true
                }
                unless found
                  if from.is_object_store?
                    error_message "Cannot find any containers, use `#{selfname} containers:add <name>` to create one.", :not_found
                  elsif from.isDirectory() == false
                    error_message "Cannot find resource named '#{name}'.", :not_found
                  end
                end
              else
                error_message from.error_string, from.error_code
              end
            rescue Exception => e
              error_message "Exception reading '#{name}': " + e.to_s, :general_error
            end
          }
        }
      end
    end
  end
end

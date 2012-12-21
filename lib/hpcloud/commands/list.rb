require 'hpcloud/resource_factory'

module HP
  module Cloud
    class CLI < Thor
    
      map %w(ls containers containers:list) => 'list'
      map 'ls' => 'list'
    
      desc 'list [container ...]', "List containers or container contents."
      long_desc <<-DESC
  List containers or the contents of the specified containers. Optionally, an availability zone can be passed.

Examples:
  hpcloud list :tain1/sub/ :tain2/sub/          # List the contents of the subdirectory `/sub/` in `tain1` and `tain2`:
  hpcloud list :tain1/.*png                     # List the PNG files in `tain1`:
  hpcloud list :tainer                          # List all the objects in container `tainer`:
  hpcloud list                                  # List all containers:
  hpcloud list :my_container -z region-a.geo-1  # List all the objects in container `my_container` for availability zone `region-a.geo-1`:

Aliases: ls
      DESC
      CLI.add_common_options
      def list(*sources)
        cli_command(options) {
          sources = [""] if sources.empty?
          multi = sources.length > 1
          sources.each { |name|
            begin
              from = ResourceFactory.create(Connection.instance.storage, name)
              if from.valid_source()
                found = false
                from.foreach { |file|
                  if from.is_container?
                    if multi
                      @log.display file.fname
                    else
                      @log.display file.path
                    end
                  else
                    if file.is_container?
                      @log.display file.container
                    else
                      @log.display file.fname
                    end
                  end
                  found = true
                }
                unless found
                  if from.is_object_store?
                    @log.error "Cannot find any containers, use `#{selfname} containers:add <name>` to create one.", :not_found
                  elsif from.isDirectory() == false
                    @log.error "Cannot find resource named '#{name}'.", :not_found
                  end
                end
              else
                @log.error from.error_string, from.error_code
              end
            rescue Exception => e
              @log.error "Exception reading '#{name}': " + e.to_s, :general_error
            end
          }
        }
      end
    end
  end
end

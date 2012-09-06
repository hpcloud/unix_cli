module HP
  module Cloud
    class CLI < Thor
    
      map 'mv' => 'move'
    
      desc 'move <object> <object>', 'move objects inside or between containers'
      long_desc <<-DESC
  Move objects inside a container or between containers. The source file will be
  removed after transfer is successful. Optionally specify an availability zone can be passed.
  For copying files to and from your local filesystem see `copy`.

Examples:
  hpcloud move :my_container/file.txt :my_container/old/backup.txt
  hpcloud move :my_container/file.txt :other_container/file.txt
  hpcloud move :my_container/file.txt :my_container/old/backup.txt -z region-a.geo-1  # Optionally specify an availability zone

Aliases: mv
      DESC
      CLI.add_common_options
      def move(from,to)
        cli_command(options) {
          from_type = Resource.detect_type(from)
          to_type   = Resource.detect_type(to)
          if from_type != :object
            error "Move is limited to objects within containers. Please use '#{selfname} copy' instead.", :incorrect_usage
          else
            silence_display do
              begin
                copy(from, to)
              rescue SystemExit => error
                exit error.status if error.success? == false
              end
              begin
                remove(from)
              rescue SystemExit => error
                exit error.status if error.success? == false
              end
            end
            # any errors will be handled by above functions
            display "Moved #{from} => #{to}"
          end
        }
      end
    end
  end
end

module HP
  module Cloud
    class CLI < Thor
    
      map 'mv' => 'move'
    
      desc 'move <source ...> <destination>', 'Move objects inside or between containers.'
      long_desc <<-DESC
  Move objects to a new location inside a container or between containers. The source file is removed after a successful transfer. If you specify more than one source, the destination must be a container, or a directory ending in `/`.  Optionally, you can specify an availability zone.  For copying files to and from your local filesystem see `copy`.

Examples:
  hpcloud move :my_container/file.txt :my_container/old/backup.txt # Move file `file.txt` to new name and location `old/backup.txt` in container `my_container`:
  hpcloud move :my_container/file.txt :other_container/file.txt #  Move file `file.txt` from container `my_container` to container `other_container`:
  hpcloud move :tain/f1.txt :tain/f2.txt :othertain/directory/  # Move files `f1.txt` and f2.txt` from container `tain` to directory `/directory` in container `othertain`:
  hpcloud move :my_container/file.txt :my_container/old/backup.txt -z region-a.geo-1  # Move file `file.txt` to new name and location `old/backup.txt` in container `my_container` for availability zone `region-a.geo-1`:

Aliases: mv
      DESC
      CLI.add_common_options
      def move(source, *destination)
        cli_command(options) {
          last = destination.pop
          if last.nil?
            error "To move you must specify a source and a destination", :incorrect_usage
          end
          source = [source] + destination
          destination = last
          to = Resource.create(Connection.instance.storage, destination)
          if source.length > 1 && to.isDirectory() == false
            error("The destination '#{destination}' for multiple files must be a directory or container", :general_error)
          end
          source.each { |name|
            from = Resource.create(Connection.instance.storage, name)
            if from.isLocal()
              error_message "Move is limited to remote objects. Please use '#{selfname} copy' instead.", :incorrect_usage
              next
            end
            if to.copy(from)
              if from.remove(false)
                display "Moved #{from.fname} => #{to.fname}"
              else
                error_message from.error_string, from.error_code
              end
            else
              error_message to.error_string, to.error_code
            end
          }
        }
      end
    end
  end
end

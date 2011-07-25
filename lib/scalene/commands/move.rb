module HP
  module Scalene
    class CLI < Thor
    
      map 'mv' => 'move'
    
      desc 'move <object> <object>', 'move objects inside or between containers'
      long_desc <<-DESC
  Move objects inside a container or between containers. The source file will be
  removed after transfer is successful. For copying files to and from your 
  local filesystem see `copy`.

Examples:
  scalene move :my_container/file.txt :my_container/old/backup.txt
  scalene move :my_container/file.txt :other_container/file.txt

Aliases: mv
      DESC
      def move(from,to)
        from_type = Resource.detect_type(from)
        to_type   = Resource.detect_type(to)
        if from_type != :object
          error "Move is limited to objects within containers. Please use '#{selfname} copy' instead.", :incorrect_usage
        else
          silence_display do
            copy(from, to)
            remove(from)
          end
          # any errors will be handled by above functions
          display "Moved #{from} => #{to}"
        end
      end
    
    end
  end
end
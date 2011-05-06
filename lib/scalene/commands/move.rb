module HP
  module Scalene
    class CLI < Thor
    
      map 'mv' => 'move'
    
      desc 'move <object> <object>', 'move objects inside or between buckets'
      long_desc <<-DESC
  Move objects inside a bucket or between buckets. The source file will be 
  removed after transfer is successful. For copying files to and from your 
  local filesystem see `copy`.

Examples:
  scalene move :my_bucket/file.txt :my_bucket/old/backup.txt
  scalene move :my_bucket/file.txt :other_bucket/file.txt

Aliases: mv

Note: Moving between buckets is pending a bugfix in the KSV system and is
  temporarily disabled in the CLI.
      DESC
      def move(from,to)
        from_type = Resource.detect_type(from)
        to_type   = Resource.detect_type(to)
        if from_type != :object
          error "Move is limited to objects within buckets. Please use '#{selfname} copy' instead.", :incorrect_usage
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
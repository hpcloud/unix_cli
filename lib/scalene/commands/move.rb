module HP
  module Scalene
    class CLI < Thor
    
      map 'mv' => 'move'
    
      desc 'move <resource> <resource>', 'move objects inside or between buckets'
      long_desc "Move objects inside a bucket or between two buckets.
                \n\nExamples:
                \n\nscalene move :my_bucket/my_file.txt :my_bucket/new_file.txt ==> Move a file within a bucket
                \n\nscalene mv :my_bucket/file.txt :my_other_bucket ==> Move a file from one bucket to another bucket

                \n\nAliases: 'mv'
                \n\nNote: we don\'t yet support the ability to move files \nwith a wildcard, i.e. '*.*',
                or to move entire directories."
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
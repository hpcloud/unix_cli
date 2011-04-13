module HP
  module Scalene
    class CLI < Thor
    
      map 'mv' => 'move'
    
      desc 'move <resource> <resource>', 'move objects inside or between buckets'
      def move(from,to)
        from_type = Resource.detect_type(from)
        to_type   = Resource.detect_type(to)
        if from_type != :object
          error "Move is limited to objects within buckets. Please use 'scalene copy' instead."
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
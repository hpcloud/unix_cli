module HP
  module Scalene
    class CLI < Thor
    
      desc 'touch <resource>', "create an empty object"
      def touch(resource)
        display "touch an object"
      end
    
    end
  end
end
module HP
  module Scalene
    class CLI < Thor
    
      desc 'touch <resource>', "create an empty object"
      long_desc "Create an empty, zero-sized object (file)
                \n\nExamples:
                \n\nscalene touch :my_container/an_empty_file.txt ==> Create a new file called 'my_file.txt'
                \n\nAliases: none"

      def touch(resource)
        display "touch an object"
      end
    
    end
  end
end
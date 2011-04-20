module HP
  module Scalene
    class CLI < Thor
    
      desc 'versioning <bucket>', 'show or modify versioning state for a bucket'
      long_desc "Show or set the versioning state for a bucket.
                \n\nExamples:
                \n\nscalene versioning :my_bucket
                \n\nAliases: none
      def versioning(new_state=nil)
        display "show versioning state"
      end

    end
  end
end
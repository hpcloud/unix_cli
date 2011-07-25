module HP
  module Cloud
    class CLI < Thor
    
      desc 'versioning <container>', 'show or modify versioning state for a container'
      long_desc "Show or set the versioning state for a container.
                \n\nExamples:
                \n\nhpcloud versioning :my_container
                \n\nAliases: none"
      def versioning(new_state=nil)
        display "show versioning state"
      end

    end
  end
end
module HP
  module Cloud
    class CLI < Thor
    
      desc 'touch <resource>', "create an empty object"
      long_desc <<-DESC
  Create an empty, zero-sized object (file)

Examples:
  hpcloud touch :my_container/an_empty_file.txt     # Create a new file called 'my_file.txt'

Aliases: none
      DESC
      GOPTS.each { |k,v| method_option(k, v) }
      def touch(resource)
        display "touch an object"
      end
    
    end
  end
end

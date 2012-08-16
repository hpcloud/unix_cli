module HP
  module Cloud
    class CLI < Thor
    
      desc 'versioning <container>', 'show or modify versioning state for a container'
      long_desc <<-DESC
  Show or set the versioning state for a container.

Examples:
  hpcloud versioning :my_container

Aliases: none
      DESC
      GOPTS.each { |k,v| method_option(k, v) }
      def versioning(new_state=nil)
        display "show versioning state"
      end

    end
  end
end

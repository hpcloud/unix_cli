module HP
  module Cloud
    class CLI < Thor
    
      map '--version' => 'info'
    
      desc "info", "info about the HP Cloud CLI"
      def info
        display "version: #{VERSION}"
      end
    
    end
  end
end
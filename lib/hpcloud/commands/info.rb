module HP
  module Cloud
    class CLI < Thor
    
      map '--version' => 'info'
    
      desc "info", "Display info about the HP Cloud UNIX CLI."
      def info
        display "******************************************************************"
        display " HP Cloud CLI"
        display " Command-line interface for managing HP Cloud services"
        display "\n Version: #{VERSION}"
        display "\n Copyright (c) 2011 Hewlett-Packard Development Company, L.P."
        display "******************************************************************"
      end
    
    end
  end
end
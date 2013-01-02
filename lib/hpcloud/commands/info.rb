module HP
  module Cloud
    class CLI < Thor
    
      map '--version' => 'info'
    
      desc "info", "Display info about the HP Cloud UNIX CLI."
      def info
        @log.display "******************************************************************"
        @log.display " HP Cloud CLI"
        @log.display " Command-line interface for managing HP Cloud services"
        @log.display "\n Version: #{VERSION}"
        @log.display "    SHA1: #{SHA1}"
        @log.display "\n Copyright (c) 2011 Hewlett-Packard Development Company, L.P."
        @log.display "******************************************************************"
      end
    
    end
  end
end

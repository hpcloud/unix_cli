module HP
  module Scalene
    class CLI < Thor
    
      map '--version' => 'info'
    
      desc "info", "info about the HP Scalene CLI"
      def info
        display "version: #{VERSION}"
      end
    
    end
  end
end
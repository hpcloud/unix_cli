require 'hpcloud/flavors'

module HP
  module Cloud
    class CLI < Thor

      map 'flavors:list' => 'flavors'

      desc "flavors", "list of available flavors"
      long_desc <<-DESC
  List the flavors in your compute account.

Examples:
  hpcloud flavors

Aliases: flavors:list
      DESC
      def flavors
        begin
          # Need specific flavors for HP
          #flavors = connection(:compute).flavors
          flavors = HP::Cloud::Flavors.all
          if flavors.empty?
            display "You currently have no flavors."
          else
            HP::Cloud::Flavors.table(flavors)
          end
        rescue Excon::Errors::Forbidden => error
          display_error_message(error)
        end
      end

    end
  end
end
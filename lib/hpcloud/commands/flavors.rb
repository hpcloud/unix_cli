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
          flavors = connection(:compute, options).flavors
          if flavors.empty?
            display "You currently have no flavors."
          else
            # :rxtx_cap, :rxtx_quota, :swap, :vcpus are not attributes on model
            flavors.table([:id, :name, :ram, :disk])
          end
        rescue Exception => error
          display_error_message(error, :general_error)
        end
      end

    end
  end
end
module HP
  module Cloud
    class CLI < Thor

      map 'keypairs:list' => 'keypairs'

      desc "keypairs", "list of available keypairs"
      long_desc <<-DESC
  List the keypairs in your compute account.

Examples:
  hpcloud keypairs

Aliases: keypairs:list
      DESC
      def keypairs
        begin
          keypairs = connection(:compute).key_pairs
          if keypairs.empty?
            display "You currently have no keypairs to use."
          else
            keypairs.table([:name, :fingerprint])
          end
        rescue Excon::Errors::Forbidden => error
          display_error_message(error)
        end
      end

    end
  end
end
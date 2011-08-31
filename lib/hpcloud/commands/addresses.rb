require 'hpcloud/commands/addresses/add'
require 'hpcloud/commands/addresses/remove'
require 'hpcloud/commands/addresses/assign'

module HP
  module Cloud
    class CLI < Thor

      map 'addresses:list' => 'addresses'

      desc "addresses", "list of available addresses"
      long_desc <<-DESC
  List the available addresses in your compute account.

Examples:
  hpcloud addresses

Aliases: addresses:list
      DESC
      def addresses
        begin
          addresses = connection(:compute).addresses
          if addresses.empty?
            display "You currently have no addresses, use `#{selfname} addresses:add` to create one."
          else
            addresses.table([:public_ip, :server_id])
          end
        rescue Excon::Errors::Forbidden => error
          display_error_message(error)
        end
      end

    end
  end
end
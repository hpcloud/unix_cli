require 'hpcloud/commands/addresses/add'
require 'hpcloud/commands/addresses/remove'
require 'hpcloud/commands/addresses/associate'
require 'hpcloud/commands/addresses/disassociate'

module HP
  module Cloud
    class CLI < Thor

      map 'addresses:list' => 'addresses'

      desc "addresses", "list of available addresses"
      long_desc <<-DESC
  List the available addresses for your account. Optionally, an availability zone can be passed.

Examples:
  hpcloud addresses                            # List addresses
  hpcloud addresses -z az-2.region-a.geo-1     # Optionally specify an availability zone

Aliases: addresses:list
      DESC
      GOPTS.each { |k,v| method_option(k, v) }
      def addresses
        begin
          addresses = connection(:compute, options).addresses
          if addresses.empty?
            display "You currently have no public IP addresses, use `#{selfname} addresses:add` to create one."
          else
            addresses.table([:id, :ip, :fixed_ip, :instance_id])
          end
        rescue Fog::HP::Errors::ServiceError, Fog::Compute::HP::Error => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden, Excon::Errors::Conflict => error
          display_error_message(error, :permission_denied)
        end
      end

    end
  end
end

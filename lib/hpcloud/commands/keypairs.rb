require 'hpcloud/commands/keypairs/import'
require 'hpcloud/commands/keypairs/add'
require 'hpcloud/commands/keypairs/remove'

module HP
  module Cloud
    class CLI < Thor

      map 'keypairs:list' => 'keypairs'

      desc "keypairs", "list of available keypairs"
      long_desc <<-DESC
  List the keypairs in your compute account. Optionally, an availability zone can be passed.

Examples:
  hpcloud keypairs                           # List keypairs
  hpcloud keypairs -z az-2.region-a.geo-1    # Optionally specify an availability zone

Aliases: keypairs:list
      DESC
      method_option :availability_zone,
                    :type => :string, :aliases => '-z',
                    :desc => 'Set the availability zone.'
      def keypairs
        begin
          keypairs = connection(:compute, options).key_pairs
          if keypairs.empty?
            display "You currently have no keypairs to use."
          else
            keypairs.table([:name, :fingerprint])
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
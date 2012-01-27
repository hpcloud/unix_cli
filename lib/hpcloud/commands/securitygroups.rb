require 'hpcloud/commands/securitygroups/add'
require 'hpcloud/commands/securitygroups/remove'
require 'hpcloud/commands/securitygroups/ippermissions'

module HP
  module Cloud
    class CLI < Thor

      map 'securitygroups:list' => 'securitygroups'

      desc "securitygroups", "list of available security groups"
      long_desc <<-DESC
  List the security groups in your compute account.

Examples:
  hpcloud securitygroups

Aliases: securitygroups:list
      DESC
      def securitygroups
        begin
          securitygroups = connection(:compute).security_groups
          if securitygroups.empty?
            display "You currently have no security groups."
          else
            securitygroups.table([:name, :description, :owner_id])
          end
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
      end

    end
  end
end
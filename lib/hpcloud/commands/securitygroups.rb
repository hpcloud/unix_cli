require 'hpcloud/commands/securitygroups/add'
require 'hpcloud/commands/securitygroups/remove'
require 'hpcloud/commands/securitygroups/rules'

module HP
  module Cloud
    class CLI < Thor

      map 'securitygroups:list' => 'securitygroups'

      desc "securitygroups", "list of available security groups"
      long_desc <<-DESC
  List the security groups in your compute account. Optionally, an availability zone can be passed.

Examples:
  hpcloud securitygroups                         # List security groups
  hpcloud securitygroups -z az-2.region-a.geo-1  # List security groups for an availability zone

Aliases: securitygroups:list
      DESC
      CLI.add_common_options
      def securitygroups
        cli_command(options) {
          securitygroups = connection(:compute, options).security_groups
          if securitygroups.empty?
            display "You currently have no security groups."
          else
            securitygroups.table([:id, :name, :description])
          end
        }
      end
    end
  end
end

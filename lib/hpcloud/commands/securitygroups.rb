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
      def securitygroups(*arguments)
        cli_command(options) {
          securitygroups = SecurityGroups.new
          if securitygroups.empty?
            display "You currently have no security groups, , use `#{selfname} securitygroups:add <name>` to create one."
          else
            hsh = securitygroups.get_hash(arguments)
            if hsh.empty?
              display "There are no security groups that match the provided arguments"
            else
              tablelize(hsh, SecurityGroupHelper.get_keys())
            end
          end
        }
      end
    end
  end
end

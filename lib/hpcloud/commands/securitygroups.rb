require 'hpcloud/commands/securitygroups/add'
require 'hpcloud/commands/securitygroups/remove'
require 'hpcloud/commands/securitygroups/rules'

module HP
  module Cloud
    class CLI < Thor

      map 'securitygroups:list' => 'securitygroups'

      desc "securitygroups [name_or_id ...]", "list of available security groups"
      long_desc <<-DESC
  List the security groups in your compute account. You may filter the display by specifying names or ids of security groups on the command line.  Optionally, an availability zone can be passed.

Examples:
  hpcloud securitygroups                         # List security groups
  hpcloud securitygroups mysecgrp                # List mysecgrp security group
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
              Tableizer.new(options, SecurityGroupHelper.get_keys(), hsh).print
            end
          end
        }
      end
    end
  end
end

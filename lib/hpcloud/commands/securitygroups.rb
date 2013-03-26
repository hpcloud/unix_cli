require 'hpcloud/commands/securitygroups/add'
require 'hpcloud/commands/securitygroups/remove'
require 'hpcloud/commands/securitygroups/rules'

module HP
  module Cloud
    class CLI < Thor

      map 'securitygroups:list' => 'securitygroups'

      desc "securitygroups [name_or_id ...]", "List the available security groups."
      long_desc <<-DESC
  List the security groups in your compute account. You may filter the display by specifying names or IDs of security groups on the command line.  Optionally, you can specify an availability zone.

Examples:
  hpcloud securitygroups                         # List the security groups:
  hpcloud securitygroups mysecgrp                # List security group `mysecgrp`:
  hpcloud securitygroups -z az-2.region-a.geo-1  # List the security groups for availability zone `az-2.region-a.geo-1`:

Aliases: securitygroups:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      def securitygroups(*arguments)
        cli_command(options) {
          securitygroups = SecurityGroups.new
          if securitygroups.empty?
            @log.display "You currently have no security groups, , use `#{selfname} securitygroups:add <name>` to create one."
          else
            ray = securitygroups.get_array(arguments)
            if ray.empty?
              @log.display "There are no security groups that match the provided arguments"
            else
              Tableizer.new(options, SecurityGroupHelper.get_keys(), ray).print
            end
          end
        }
      end
    end
  end
end

require 'hpcloud/commands/securitygroups/rules/add'
require 'hpcloud/commands/securitygroups/rules/remove'

module HP
  module Cloud
    class CLI < Thor

      map 'securitygroups:rules:list' => 'securitygroups:rules'

      desc "securitygroups:rules <sec_group_name>", "Display the list of rules for a security group."
      long_desc <<-DESC
  List the rules for a security group for your compute account. Optionally, you can specify an availability zone.

Examples:
  hpcloud securitygroups:rules mysecgroup  # List the rules for security group `mysecgroup`:
  hpcloud securitygroups:rules mysecgroup -z az-2.region-a.geo-1   # List the rules for security group `mysecgroup` for availability zone `az-2.region-a.geo-1`:

Aliases: securitygroups:rules:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      define_method "securitygroups:rules" do |sec_group_name|
        cli_command(options) {
          rules = Rules.new(sec_group_name)
          if rules.empty?
            @log.display "You currently have no rules for the security group '#{sec_group_name}'."
          else
            ray = rules.get_array
            Tableizer.new(options, RuleHelper.get_keys(), ray).print
          end
        }
      end
    end
  end
end

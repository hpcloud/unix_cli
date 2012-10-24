require 'hpcloud/rules'
require 'hpcloud/commands/securitygroups/rules/add'
require 'hpcloud/commands/securitygroups/rules/remove'

module HP
  module Cloud
    class CLI < Thor

      map 'securitygroups:rules:list' => 'securitygroups:rules'

      desc "securitygroups:rules <sec_group_name>", "Display the list of rules for a security group."
      long_desc <<-DESC
  List the rules for a security group for your compute account. Optionally, an availability zone can be passed.

Examples:
  hpcloud securitygroups:rules mysecgroup
  hpcloud securitygroups:rules mysecgroup -z az-2.region-a.geo-1   # Optionally specify an availability zone

Aliases: securitygroups:rules:list
      DESC
      CLI.add_common_options
      define_method "securitygroups:rules" do |sec_group_name|
        cli_command(options) {
          security_group = SecurityGroups.new.get(sec_group_name)
          if security_group.is_valid? == false
            error "You don't have a security group '#{sec_group_name}'.", :not_found
          end

          rules = security_group.fog.rules
          if rules.empty?
            display "You currently have no rules for the security group '#{sec_group_name}'."
          else
            Rules.table(rules)
          end
        }
      end
    end
  end
end

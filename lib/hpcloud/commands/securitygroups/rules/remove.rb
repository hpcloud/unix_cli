module HP
  module Cloud
    class CLI < Thor

      map %w(securitygroups:rules:rm securitygroups:rules:revoke securitygroups:rules:delete securitygroups:rules:del) => 'securitygroups:rules:remove'

      desc "securitygroups:rules:remove <sec_group_name> <rule_id>", "Remove a rule from the security group."
      long_desc <<-DESC
  Remove a rule from the security group, specifyied its ID. Optionally, you can specify an availability zone.

Examples:
  hpcloud securitygroups:rules:remove mysecgroup 111  # Remove the rule `mysecgroup` from security group `111`:
  hpcloud securitygroups:rules:remove mysecgroup 111 -z az-2.region-a.geo-1    # Remove the rule `mysecgroup` from security group `111` for availability zone `az-2.region-a.geo-1`:

Aliases: securitygroups:rules:rm, securitygroups:rules:revoke, securitygroups:rules:delete, securitygroups:rules:del
      DESC
      CLI.add_common_options
      define_method "securitygroups:rules:remove" do |sec_group_name, rule_id|
        cli_command(options) {
          security_group = SecurityGroups.new.get(sec_group_name)
          if security_group.is_valid? == false
            @log.fatal "You don't have a security group '#{sec_group_name}'.", :not_found
          end

          security_group.fog.delete_rule(rule_id)
          @log.display "Removed rule '#{rule_id}' for security group '#{sec_group_name}'."
        }
      end
    end
  end
end

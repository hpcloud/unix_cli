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
      define_method "securitygroups:rules:remove" do |*rule_ids|
        cli_command(options) {
          rule_ids.each { |rule_id|
            sub_command("removing security group rule") {
              Connection.instance.network.delete_security_group_rule(rule_id)
              @log.display "Removed rule '#{rule_id}'."
            }
          }
        }
      end
    end
  end
end

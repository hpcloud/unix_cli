module HP
  module Cloud
    class CLI < Thor

      map %w(securitygroups:rules:rm securitygroups:rules:revoke securitygroups:rules:delete securitygroups:rules:del) => 'securitygroups:rules:remove'

      desc "securitygroups:rules:remove rule_id [rule_id...]", "Remove security group rules."
      long_desc <<-DESC
  Remove the specified security group rules.  More than one rule may be specified on the command line.

Examples:
  hpcloud securitygroups:rules:remove 111     # Remove the rule `111`:
  hpcloud securitygroups:rules:remove 111 222 # Remove the rule `111` and `222`:

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

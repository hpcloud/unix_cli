module HP
  module Cloud
    class CLI < Thor

      map %w(securitygroups:rm securitygroups:delete securitygroups:del) => 'securitygroups:remove'

      desc "securitygroups:remove name_or_id [name_or_id ...]", "Remove a security group or groups."
      long_desc <<-DESC
  Remove existing security groups by name or ID. Optionally, you can specify an availability zone.

Examples:
  hpcloud securitygroups:remove group1 group2 # Remove the security groups `group1` and `group2`:
  hpcloud securitygroups:remove 30725         # Remove the security group with the ID `30725`:
  hpcloud securitygroups:remove mysecgroup -z az-2.region-a.geo-1   # Remove the security group `mysecgroup` for availability zone `az-2.region-a.geo-1`:

Aliases: securitygroups:rm, securitygroups:delete, securitygroups:del
      DESC
      CLI.add_common_options
      define_method "securitygroups:remove" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          securitygroups = SecurityGroups.new.get(name_or_ids, false)
          securitygroups.each { |securitygroup|
            sub_command("removing security group") {
              if securitygroup.is_valid?
                securitygroup.destroy
                @log.display "Removed security group '#{securitygroup.name}'."
              else
                @log.error securitygroup.cstatus
              end
            }
          }
        }
      end
    end
  end
end

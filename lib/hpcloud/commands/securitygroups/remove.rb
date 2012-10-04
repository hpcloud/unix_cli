module HP
  module Cloud
    class CLI < Thor

      map %w(securitygroups:rm securitygroups:delete securitygroups:del) => 'securitygroups:remove'

      desc "securitygroups:remove name_or_id [name_or_id ...]", "remove security groups"
      long_desc <<-DESC
  Remove existing security groups by name or id. Optionally, an availability zone can be passed.

Examples:
  hpcloud securitygroups:remove group1 group2 # Remove two groups group1 and group2
  hpcloud securitygroups:remove 30725         # Remove group by identifier
  hpcloud securitygroups:remove mysecgroup -z az-2.region-a.geo-1   # Optionally specify an availability zone

Aliases: securitygroups:rm, securitygroups:delete, securitygroups:del
      DESC
      CLI.add_common_options
      define_method "securitygroups:remove" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          securitygroups = SecurityGroups.new.get(name_or_ids, false)
          securitygroups.each { |securitygroup|
            begin
              if securitygroup.is_valid?
                securitygroup.destroy
                display "Removed security group '#{securitygroup.name}'."
              else
                error_message(securitygroup.error_string, securitygroup.error_code)
              end
            rescue Exception => e
              error_message("Error removing security group: " + e.to_s, :general_error)
            end
          }
        }
      end
    end
  end
end

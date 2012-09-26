module HP
  module Cloud
    class CLI < Thor

      map %w(securitygroups:rm securitygroups:delete securitygroups:del) => 'securitygroups:remove'

      desc "securitygroups:remove <name>", "remove a security group"
      long_desc <<-DESC
  Remove an existing security group by name. Optionally, an availability zone can be passed.

Examples:
  hpcloud securitygroups:remove mysecgroup
  hpcloud securitygroups:remove mysecgroup -z az-2.region-a.geo-1   # Optionally specify an availability zone

Aliases: securitygroups:rm, securitygroups:delete, securitygroups:del
      DESC
      CLI.add_common_options
      define_method "securitygroups:remove" do |name, *names|
        cli_command(options) {
          names = [name] + names
          securitygroups = SecurityGroups.new.get(names, false)
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

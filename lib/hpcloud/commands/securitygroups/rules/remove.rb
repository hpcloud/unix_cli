module HP
  module Cloud
    class CLI < Thor

      map %w(securitygroups:rules:rm securitygroups:rules:revoke securitygroups:rules:delete securitygroups:rules:del) => 'securitygroups:rules:remove'

      desc "securitygroups:rules:remove <sec_group_name> <rule_id>", "remove a rule from the security group"
      long_desc <<-DESC
  Remove a rule by specifying its id, from the security group. Optionally, an availability zone can be passed.

Examples:
  hpcloud securitygroups:rules:remove mysecgroup 111
  hpcloud securitygroups:rules:remove mysecgroup 111 -z az-2.region-a.geo-1    # Optionally specify an availability zone

Aliases: securitygroups:rules:rm, securitygroups:rules:revoke, securitygroups:rules:delete, securitygroups:rules:del
      DESC
      CLI.add_common_options()
      define_method "securitygroups:rules:remove" do |sec_group_name, rule_id|
        begin
          compute_connection = connection(:compute, options)
          security_group = compute_connection.security_groups.select {|sg| sg.name == sec_group_name}.first
          if (security_group && security_group.name == sec_group_name)
            security_group.delete_rule(rule_id)
            display "Removed rule '#{rule_id}' for security group '#{sec_group_name}'."
          else
            error "You don't have a security group '#{sec_group_name}'.", :not_found
          end
        rescue Fog::HP::Errors::ServiceError, Excon::Errors::BadRequest, Fog::Compute::HP::Error => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
      end


    end
  end
end

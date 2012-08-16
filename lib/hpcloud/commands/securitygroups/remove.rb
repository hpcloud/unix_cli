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
      GOPTS.each { |k,v| method_option(k, v) }
      define_method "securitygroups:remove" do |sec_group_name|
        begin
          compute_connection = connection(:compute, options)
          security_group = compute_connection.security_groups.select {|sg| sg.name == sec_group_name}.first
          if (security_group && security_group.name == sec_group_name)
            security_group.destroy
            display "Removed security group '#{sec_group_name}'."
          else
            error "You don't have a security group '#{sec_group_name}'.", :not_found
          end
        rescue Fog::HP::Errors::ServiceError, Fog::Compute::HP::Error => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
      end

    end
  end
end

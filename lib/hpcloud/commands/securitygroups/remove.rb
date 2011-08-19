module HP
  module Cloud
    class CLI < Thor

      map %w(securitygroups:delete securitygroups:del) => 'securitygroups:remove'

      desc "securitygroups:remove <name>", "remove a security group"
      long_desc <<-DESC
  Remove an existing security group by name.

Examples:
  hpcloud securitygroups:remove mysecgroup

Aliases: securitygroups:delete, securitygroups:del
      DESC
      define_method "securitygroups:remove" do |sec_group_name|
        begin
          compute_connection = connection(:compute)
          security_group = compute_connection.security_groups.select {|sg| sg.name == sec_group_name}.first
        rescue Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
        if (security_group && security_group.name == sec_group_name)
          begin
            security_group.destroy
            display "Removed security group '#{sec_group_name}'."
          rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
            display_error_message(error)
          end
        else
          error "You don't have a security group '#{sec_group_name}'.", :not_found
        end
      end

    end
  end
end
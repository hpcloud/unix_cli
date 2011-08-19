module HP
  module Cloud
    class CLI < Thor

      desc "securitygroups:add <name> <description>", "add a security group"
      long_desc <<-DESC
  Add a new security group by specifying a name and a description.

Examples:
  hpcloud securitygroups:add mysecgroup "seg group desc"

Aliases: none
      DESC
      define_method "securitygroups:add" do |sec_group_name, sg_desc|
        begin
          compute_connection = connection(:compute)
          security_group = compute_connection.security_groups.select {|sg| sg.name == sec_group_name}.first
          if (security_group && security_group.name == sec_group_name)
            display "Security group '#{sec_group_name}' already exists."
          else
            security_group = compute_connection.security_groups.new(:name => sec_group_name, :description => sg_desc)
            security_group.save
            display "Created security group '#{sec_group_name}'."
          end
        rescue Fog::AWS::Compute::Error => error
          display_error_message(error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
      end

    end
  end
end
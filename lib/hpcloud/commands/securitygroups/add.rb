module HP
  module Cloud
    class CLI < Thor

      desc "securitygroups:add <name> <description>", "add a security group"
      long_desc <<-DESC
  Add a new security group by specifying a name and a description. Optionally, an availability zone can be passed.

Examples:
  hpcloud securitygroups:add mysecgroup "seg group desc"
  hpcloud securitygroups:add mysecgroup "seg group desc" -z az-2.region-a.geo-1  # Optionally specify an availability zone
      DESC
      CLI.add_common_options
      define_method "securitygroups:add" do |sec_group_name, sg_desc|
        cli_command(options) {
          if SecurityGroups.new.get(sec_group_name).is_valid? == true
            error "Security group '#{sec_group_name}' already exists.", :general_error
          end

          security_group = SecurityGroupHelper.new(Connection.instance)
          security_group.name = sec_group_name
          security_group.description = sg_desc
          if security_group.save == true
            display "Created security group '#{sec_group_name}' with id '#{security_group.id}'."
          else
            error(security_group.error_string, security_group.error_code)
          end
        }
      end
    end
  end
end

module HP
  module Cloud
    class CLI < Thor

      desc "securitygroups:add <name> <description>", "Add a security group."
      long_desc <<-DESC
  Add a new security group by specifying a name and a description. Optionally, you can specify an availability zone.

Examples:
  hpcloud securitygroups:add mysecgroup "seg group desc"  # Add new security group `mysecgroup` with description `seg group desc`:
  hpcloud securitygroups:add mysecgroup "seg group desc" -z az-2.region-a.geo-1  # Add new security group `mysecgroup` with description `seg group desc` for availability zone `az-2.region-a.geo-1`:
      DESC
      CLI.add_common_options
      define_method "securitygroups:add" do |sec_group_name, sg_desc|
        cli_command(options) {
          if SecurityGroups.new.get(sec_group_name).is_valid? == true
            @log.fatal "Security group '#{sec_group_name}' already exists."
          end

          security_group = SecurityGroupHelper.new(Connection.instance)
          security_group.name = sec_group_name
          security_group.description = sg_desc
          if security_group.save == true
            @log.display "Created security group '#{sec_group_name}' with id '#{security_group.id}'."
          else
            @log.fatal security_group.cstatus
          end
        }
      end
    end
  end
end

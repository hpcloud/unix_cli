module HP
  module Cloud
    class CLI < Thor

      desc "securitygroups:add <name> <description>", "add a security group"
      long_desc <<-DESC
  Add a new security group by specifying a name and a description. Optionally, an availability zone can be passed.

Examples:
  hpcloud securitygroups:add mysecgroup "seg group desc"
  hpcloud securitygroups:add mysecgroup "seg group desc" -z az-2.region-a.geo-1  # Optionally specify an availability zone

Aliases: none
      DESC
      CLI.add_common_options()
      define_method "securitygroups:add" do |sec_group_name, sg_desc|
        cli_command(options) {
          compute_connection = connection(:compute, options)
          security_group = compute_connection.security_groups.select {|sg| sg.name == sec_group_name}.first
          if (security_group && security_group.name == sec_group_name)
            display "Security group '#{sec_group_name}' already exists."
          else
            security_group = compute_connection.security_groups.new(:name => sec_group_name, :description => sg_desc)
            security_group.save
            display "Created security group '#{sec_group_name}'."
          end
        }
      end
    end
  end
end

require 'hpcloud/ip_permissions'

module HP
  module Cloud
    class CLI < Thor

      map 'securitygroups:ippermissions:list' => 'securitygroups:ippermissions'

      desc "securitygroups:ippermissions <sec_group_name>", "list of ip permissions for a security group"
      long_desc <<-DESC
  List the ip permissions for a security group in your compute account.

Examples:
  hpcloud securitygroups:ippermissions mysecgroup

Aliases: securitygroups:ippermissions:list
      DESC
      define_method "securitygroups:ippermissions" do |sec_group_name|
        begin
          compute_connection = connection(:compute)
          security_group = compute_connection.security_groups.select {|sg| sg.name == sec_group_name}.first
          if (security_group && security_group.name == sec_group_name)
            ip_permissions = security_group.ip_permissions
            if ip_permissions.empty?
              display "You currently have no ip permissions for the security group '#{sec_group_name}'."
            else
              IpPermissions.table(ip_permissions)
            end
          else
            error "You don't have a security group '#{sec_group_name}'.", :not_found
          end
        rescue Excon::Errors::Forbidden => error
          display_error_message(error)
        end
      end

    end
  end
end
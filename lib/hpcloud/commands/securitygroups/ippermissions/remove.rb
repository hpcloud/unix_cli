module HP
  module Cloud
    class CLI < Thor

      map %w(securitygroups:ippermissions:revoke, securitygroups:ippermissions:delete securitygroups:ippermissions:del) => 'securitygroups:ippermissions:remove'

      desc "securitygroups:ippermissions:remove <sec_group_name> <ip_protocol> <port_range> <ip_address>", "remove an IP permission from the security group"
      long_desc <<-DESC
  Remove an IP permission from the security group. If <ip_protocol> is specified as 'icmp', then <port_range> is set to -1..-1.
  If <ip_address> is not specified, then it defaults to '0.0.0.0/0'.

Examples:
  hpcloud securitygroups:ippermissions:remove mysggroup tcp 22..22
  hpcloud securitygroups:ippermissions:remove mysggroup icmp
  hpcloud securitygroups:ippermissions:remove mysggroup tcp 80..80 "111.111.111.111/1"

Aliases: securitygroups:ippermissions:revoke, securitygroups:ippermissions:delete securitygroups:ippermissions:del
      DESC
      define_method "securitygroups:ippermissions:remove" do |sec_group_name, ip_protocol, port_range_str=nil, ip_address=nil|
        begin
          compute_connection = connection(:compute)
          security_group = compute_connection.security_groups.select {|sg| sg.name == sec_group_name}.first
          if (security_group && security_group.name == sec_group_name)
            if ip_protocol == 'icmp'
              port_range = Range.new(-1, -1)
            else
              if port_range_str.nil?
                error "You have to specify a port range for any ip protocol other than 'icmp'.", :general_error
              else
                port_range = port_range_str.split('..').inject { |s,e| s.to_i..e.to_i }
              end
            end
            security_group.revoke_port_range(port_range, {:cidr_ip => ip_address, :ip_protocol => ip_protocol})
            display "Removed IP permission for security group '#{sec_group_name}'."
          else
            error "You don't have a security group '#{sec_group_name}'.", :not_found
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
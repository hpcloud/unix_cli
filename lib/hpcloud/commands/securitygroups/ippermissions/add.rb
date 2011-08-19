module HP
  module Cloud
    class CLI < Thor

      desc "securitygroups:ippermissions:add <sec_group_name> <ip_protocol> <port_range> <ip_address>", "add an IP permission to the security group"
      long_desc <<-DESC
  Add an IP permission to the security group. If <ip_protocol> is to 'icmp', then <port_range> is set to -1..-1.
  If <ip_address> is not set, it defaults to '0.0.0.0/0'.

Examples:
  hpcloud securitygroups:ippermissions:add mysggroup tcp 22..22
  hpcloud securitygroups:ippermissions:add mysggroup icmp
  hpcloud securitygroups:ippermissions:add mysggroup tcp 80..80 "111.111.111.111/1"

Aliases: none
      DESC
      define_method "securitygroups:ippermissions:add" do |sec_group_name, ip_protocol, port_range_str=nil, ip_address=nil|
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
            security_group.authorize_port_range(port_range, {:cidr_ip => ip_address, :ip_protocol => ip_protocol})
            display "Created IP permission for security group '#{sec_group_name}'."
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
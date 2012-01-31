module HP
  module Cloud
    class CLI < Thor

      map %w(securitygroups:rules:authorize) => 'securitygroups:rules:remove'

      desc "securitygroups:rules:add <sec_group_name> <ip_protocol> <port_range> <ip_address>", "add a rule to the security group"
      long_desc <<-DESC
  Add a rule to the security group. If <ip_protocol> is specified as 'icmp', then <port_range> is set to -1..-1.
  If <ip_address> is not specified, then it defaults to '0.0.0.0/0'.

Examples:
  hpcloud securitygroups:rules:add mysggroup tcp 22..22
  hpcloud securitygroups:rules:add mysggroup icmp
  hpcloud securitygroups:rules:add mysggroup tcp 80..80 "111.111.111.111/1"

Aliases: securitygroups:rules:authorize
      DESC
      define_method "securitygroups:rules:add" do |sec_group_name, ip_protocol, port_range_str=nil, ip_address=nil|
        begin
          compute_connection = connection(:compute)
          security_group = compute_connection.security_groups.select {|sg| sg.name == sec_group_name}.first
          if (security_group && security_group.name == sec_group_name)
            if ip_protocol == 'icmp'
              # default to -1
              port_range = Range.new(-1, -1)
              unless port_range_str.nil?
                port_range = port_range_str.split('..').inject { |s,e| s.to_i..e.to_i }
              end
            else
              if port_range_str.nil?
                error "You have to specify a port range for any ip protocol other than 'icmp'.", :incorrect_usage
              else
                port_range = port_range_str.split('..').inject { |s,e| s.to_i..e.to_i }
              end
            end
            # create the security group rule
            response = security_group.create_rule(port_range, ip_protocol, ip_address)
            rule_id = response.body["security_group_rule"]["id"]
            display "Created rule '#{rule_id}' for security group '#{sec_group_name}'."
          else
            error "You don't have a security group '#{sec_group_name}'.", :not_found
          end
        rescue Excon::Errors::BadRequest, Fog::Compute::HP::Error => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
      end

    end
  end
end
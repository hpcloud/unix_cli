module HP
  module Cloud
    class CLI < Thor

      map %w(securitygroups:rules:authorize) => 'securitygroups:rules:add'

      desc "securitygroups:rules:add <sec_group_name> <ip_protocol>", "Add a rule to the security group."
      long_desc <<-DESC
  Add a rule to the security group. If <ip_protocol> is specified as 'icmp', then <port_range> is set to -1..-1.  If <ip_address> is not specified, then the address defaults to '0.0.0.0/0'. To allow communications within a given security group, you must specify a source group while creating a rule. Optionally, you can specify an availability zone.

Examples:
  hpcloud securitygroups:rules:add mysggroup icmp                                   # Set the default port range to -1..-1
  hpcloud securitygroups:rules:add mysggroup tcp -p 22..22                          # Set the default cidr to `0.0.0.0/0`:
  hpcloud securitygroups:rules:add mysggroup tcp -p 80..80 -c "111.111.111.111/1"   # Set the cidr to `111.111.111.111/1`:
  hpcloud securitygroups:rules:add mysggroup tcp -p 80..80 -g "mysourcegroup"       # Set the source group to `mysourcegroup`:
  hpcloud securitygroups:rules:add mysggroup icmp -z az-2.region-a.geo-1            # Set the availability zone to `az-2.region-a.geo-1`:

Aliases: securitygroups:rules:authorize
      DESC
      method_option :port_range,
                    :type => :string, :aliases => '-p',
                    :desc => 'Specify a port range like 22..22'
      method_option :cidr,
                    :type => :string, :aliases => '-c',
                    :desc => 'Specify a cidr ip range like 0.0.0.0/0'
      method_option :source_group,
                    :type => :string, :aliases => '-g',
                    :desc => 'Specify a source group.'
      CLI.add_common_options
      define_method "securitygroups:rules:add" do |sec_group_name, ip_protocol|
        cli_command(options) {
          src_group_id = nil
          port_range = Range.new(-1, -1)
          port_range_str = options[:port_range]
          ip_address = options[:cidr]
          src_group = options[:source_group]

          # either a source group or a cidr value can be specified
          if (src_group && ip_address)
            @log.fatal "You can either specify a source group or an ip address, not both.", :incorrect_usage
          end

          security_group = SecurityGroups.new.get(sec_group_name)
          if security_group.is_valid? == false
            @log.fatal "You don't have a security group '#{sec_group_name}'.", :not_found
          end

          # incase of icmp it defaults to -1..-1 and 0.0.0.0/0
          unless ip_protocol == 'icmp'
            if port_range_str.nil?
              @log.fatal "You have to specify a port range for any ip protocol other than 'icmp'.", :incorrect_usage
            end
          end

          # if a source group is specified, get its id
          if src_group
            source_group = Connection.instance.compute.security_groups.select {|srg| srg.name == src_group}.first
            if (source_group && source_group.name == src_group)
              src_group_id = source_group.id
            else
              @log.fatal "You don't have a source security group '#{src_group}'.", :not_found
            end
          end

          # resolve port range
          unless port_range_str.nil?
            port_range = port_range_str.split('..').inject { |s,e| s.to_i..e.to_i }
          end

          # create the security group rule
          response = security_group.fog.create_rule(port_range, ip_protocol, ip_address, src_group_id)
          rule_id = response.body["security_group_rule"]["id"]
          @log.display "Created rule '#{rule_id}' for security group '#{sec_group_name}'."
        }
      end
    end
  end
end

module HP
  module Cloud
    class CLI < Thor

      desc "servers:securitygroups:add <server> <security_group>", "Add a security group to a server."
      long_desc <<-DESC
  Add a security group to a server.

Examples:
  hpcloud servers:securitygroups:add my_server sg1   # Add the 'sg1' security group to 'my_server'
      DESC
      CLI.add_common_options
      define_method "servers:securitygroups:add" do |name_or_id, security_group|
        cli_command(options) {
          srv = Servers.new.get(name_or_id)
          if srv.is_valid?
            srv.add_security_groups(security_group)
            @log.display "Added security group '#{security_group}' to server '#{name_or_id}'."
          else
            @log.fatal srv.cstatus
          end
        }
      end
    end
  end
end

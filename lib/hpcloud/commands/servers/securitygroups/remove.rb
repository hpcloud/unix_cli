module HP
  module Cloud
    class CLI < Thor

      desc "servers:securitygroups:remove <server> <security_groups>", "Remove a security group from a server."
      long_desc <<-DESC
  Remove a security group from a server.

Examples:
  hpcloud servers:securitygroups:remove my_server sg2   # Remove security group 'sg2' from 'my_server'
      DESC
      CLI.add_common_options
      define_method "servers:securitygroups:remove" do |name_or_id, security_group|
        cli_command(options) {
          srv = Servers.new.get(name_or_id)
          if srv.is_valid?
            srv.remove_security_groups(security_group)
            @log.display "Removed security group '#{security_group}' from server '#{name_or_id}'."
          else
            @log.fatal srv.cstatus
          end
        }
      end
    end
  end
end

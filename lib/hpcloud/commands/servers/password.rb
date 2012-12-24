module HP
  module Cloud
    class CLI < Thor

      map %w(servers:passwd) => 'servers:password'

      desc "servers:password <server_name> <password>", "Change the password for a server."
      long_desc <<-DESC
  Change the password for an existing server. The password must adhere to the existing security complexity naming rules. Optionally, you can specify an availability zone.

Examples:
  hpcloud servers:password my-server my-password         # Change the password for server 'my-server':
  hpcloud servers:password my-server my-password -z az-2.region-a.geo-1   # Change the password for server 'my-server` for availability zone `az-2.region-a.geo-1`:

Aliases: servers:passwd
      DESC
      CLI.add_common_options
      define_method "servers:password" do |name, password|
        cli_command(options) {
          server = Servers.new.get(name)
          if server.is_valid?
              server.fog.change_password(password)
              @log.display "Password changed for server '#{name}'."
          else
            @log.fatal server.cstatus
          end
        }
      end

    end
  end
end

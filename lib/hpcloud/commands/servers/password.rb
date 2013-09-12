module HP
  module Cloud
    class CLI < Thor

      map %w(servers:passwd) => 'servers:password'

      desc "servers:password <server_name> <password>", "Change the password for a server."
      long_desc <<-DESC
  Change the password for an existing server. The password must adhere to the existing security complexity naming rules. Optionally, you can specify an availability zone.

Examples:
  hpcloud servers:password my-server my-password         # Change the password for server 'my-server'
  hpcloud servers:password b8e90a48 'pA$3word'         # Change the password for server 'b8e90a48'

Aliases: servers:passwd
      DESC
      CLI.add_common_options
      define_method "servers:password" do |name, password|
        cli_command(options) {
          @log.fatal "Password change is no longer supported.  Support may be added back in the future"
        }
      end

    end
  end
end

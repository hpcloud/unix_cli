module HP
  module Cloud
    class CLI < Thor

      desc "servers:reboot <name>", "reboot a server by name"
      long_desc <<-DESC
  Reboot an existing server by specifying its name. Rebooting a server may take some time
  so it might be necessary to check the status of the server by issuing command,
  'hpcloud servers'

Examples:
  hpcloud servers:reboot my-server          # reboot 'my-server'

Aliases: none
      DESC
      define_method "servers:reboot" do |name|
        begin
          # setup connection for compute service
          compute_connection = connection(:compute)
          server = compute_connection.servers.select {|s| s.name == name}.first
        rescue Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
        if server
          begin
            server.reboot
            display "Rebooting server '#{name}'."
          rescue Excon::Errors::Conflict, Excon::Errors::Forbidden => error
            display_error_message(error)
          end
        else
          error "You don't have a server '#{name}'.", :not_found
        end
      end

    end
  end
end
module HP
  module Cloud
    class CLI < Thor

      desc "servers:reboot <id>", "reboot a server by id"
      long_desc <<-DESC
  Reboot an existing server by specifying its id. Rebooting a server may take some time
  so it might be necessary to check the status of the server by issuing command,
  'hpcloud servers'

Examples:
  hpcloud servers:reboot i-00000001          # reboot 'i-00000001'

Aliases: none
      DESC
      define_method "servers:reboot" do |id|
        begin
          # setup connection for compute service
          compute_connection = connection(:compute)
          server = compute_connection.servers.select {|s| s.id == id}.first
        rescue Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
        if server
          begin
            server.reboot
            display "Rebooting server '#{id}'."
          rescue Excon::Errors::Conflict, Excon::Errors::Forbidden => error
            display_error_message(error)
          end
        else
          error "You don't have a server with '#{id}'.", :not_found
        end
      end

    end
  end
end
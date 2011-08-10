#require 'hpcloud/commands/servers/add'
#require 'hpcloud/commands/servers/remove'

module HP
  module Cloud
    class CLI < Thor

      map 'servers:list' => 'servers'

      desc "servers", "list available servers"
      long_desc <<-DESC
  List the servers in your compute account.

Examples:
  hpcloud servers

Aliases: servers:list
      DESC
      def servers
        begin
          servers = connection(:compute).servers
          if servers.empty?
            display "You currently have no servers, use `#{selfname} servers:add <name>` to create one."
          else
            servers.each { |server| display server.id }
          end
        rescue Excon::Errors::Forbidden => error
          display_error_message(error)
        end
      end

    end
  end
end
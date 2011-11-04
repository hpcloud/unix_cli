require 'hpcloud/commands/servers/add'
require 'hpcloud/commands/servers/remove'
require 'hpcloud/commands/servers/reboot'

module HP
  module Cloud
    class CLI < Thor

      map 'servers:list' => 'servers'

      desc "servers", "list of available servers"
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
            servers.table([:id, :name, :key_name, :flavor_id, :image_id, :created_at, :private_ip_address, :public_ip_address, :state])
          end
        rescue Excon::Errors::Forbidden => error
          display_error_message(error)
        end
      end

    end
  end
end
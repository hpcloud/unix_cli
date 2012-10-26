require 'hpcloud/commands/servers/add'
require 'hpcloud/commands/servers/remove'
require 'hpcloud/commands/servers/reboot'
require 'hpcloud/commands/servers/rebuild'
require 'hpcloud/commands/servers/password'
require 'hpcloud/commands/servers/metadata'
require 'hpcloud/commands/servers/metadata/add'
require 'hpcloud/commands/servers/metadata/remove'
require 'hpcloud/servers'

module HP
  module Cloud
    class CLI < Thor

      map 'servers:list' => 'servers'

      desc "servers [name_or_id ...]", "List the available servers."
      long_desc <<-DESC
  List the servers in your compute account. You may filter the list by naming the servers by name or id which you wish to display.  Optionally, an availability zone can be passed.

Examples:
  hpcloud servers                         # List servers
  hpcloud servers hal                     # List server named hal
  hpcloud servers -z az-2.region-a.geo-1  # List servers for an availability zone

Aliases: servers:list
      DESC
      CLI.add_common_options
      def servers(*arguments)
        cli_command(options) {
          servers = Servers.new
          if servers.empty?
            display "You currently have no servers, use `#{selfname} servers:add <name>` to create one."
          else
            hsh = servers.get_hash(arguments)
            if hsh.empty?
              display "There are no servers that match the provided arguments"
            else
              Tableizer.new(options, ServerHelper.get_keys(), hsh).print
            end
          end
        }
      end
    end
  end
end

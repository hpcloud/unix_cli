require 'hpcloud/commands/servers/add'
require 'hpcloud/commands/servers/console'
require 'hpcloud/commands/servers/remove'
require 'hpcloud/commands/servers/reboot'
require 'hpcloud/commands/servers/rebuild'
require 'hpcloud/commands/servers/password'
require 'hpcloud/commands/servers/metadata'
require 'hpcloud/commands/servers/metadata/add'
require 'hpcloud/commands/servers/metadata/remove'
require 'hpcloud/commands/servers/ssh'
require 'hpcloud/servers'

module HP
  module Cloud
    class CLI < Thor

      map 'servers:list' => 'servers'

      desc "servers [name_or_id ...]", "List the available servers."
      long_desc <<-DESC
  List the servers in your compute account. You may filter the list by server name or ID.  Optionally, you can specify an availability zone.

Examples:
  hpcloud servers                         # List the servers:
  hpcloud servers hal                     # List server `hal`:
  hpcloud servers -z az-2.region-a.geo-1  # List the servers for availability zone `az-2.region-a.geo-1`:

Aliases: servers:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      def servers(*arguments)
        cli_command(options) {
          servers = Servers.new
          if servers.empty?
            @log.display "You currently have no servers, use `#{selfname} servers:add <name>` to create one."
          else
            ray = servers.get_array(arguments)
            if ray.empty?
              @log.display "There are no servers that match the provided arguments"
            else
              Tableizer.new(options, ServerHelper.get_keys(), ray).print
            end
          end
        }
      end
    end
  end
end

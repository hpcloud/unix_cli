require 'hpcloud/commands/servers/add'
require 'hpcloud/commands/servers/remove'
require 'hpcloud/commands/servers/reboot'
require 'hpcloud/commands/servers/password'
require 'hpcloud/commands/servers/metadata'
require 'hpcloud/commands/servers/metadata/add'
require 'hpcloud/commands/servers/metadata/remove'
require 'hpcloud/servers'

module HP
  module Cloud
    class CLI < Thor

      map 'servers:list' => 'servers'

      desc "servers", "list of available servers"
      long_desc <<-DESC
  List the servers in your compute account. Optionally, an availability zone can be passed.

Examples:
  hpcloud servers                         # List servers
  hpcloud servers -z az-2.region-a.geo-1  # List servers for an availability zone

Aliases: servers:list
      DESC
      GOPTS.each { |k,v| method_option(k, v) }
      def servers(*arguments)
        begin
          Connection.instance.set_options(options)
          servers = Servers.new
          if servers.empty?
            display "You currently have no servers, use `#{selfname} servers:add <name>` to create one."
          else
            hsh = servers.get_hash(arguments)
            if hsh.empty?
              display "There are no servers that match the provided arguments"
            else
              tablelize(hsh, ServerHelper.get_keys())
            end
          end
        rescue Fog::HP::Errors::ServiceError, Fog::Compute::HP::Error => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
      end

    end
  end
end

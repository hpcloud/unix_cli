require 'hpcloud/commands/servers/add'
require 'hpcloud/commands/servers/remove'
require 'hpcloud/commands/servers/reboot'
require 'hpcloud/commands/servers/password'

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
      method_option :availability_zone,
                    :type => :string, :aliases => '-z',
                    :desc => 'Set the availability zone.'
      def servers
        begin
          servers = connection(:compute, options).servers
          if servers.empty?
            display "You currently have no servers, use `#{selfname} servers:add <name>` to create one."
          else
            #servers.table([:id, :name, :image_id, :flavor_id, :created_at, :key_name, :public_ip, :private_ip, :state])
            servers.table([:id, :name, :created_at, :key_name, :state])
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
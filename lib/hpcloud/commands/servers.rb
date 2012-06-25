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
            tablelize(get_server_data(servers), [:id, :name, :flavor, :image, :public_ip, :private_ip, :keyname, :security_groups, :created, :state])
          end
        rescue Fog::HP::Errors::ServiceError, Fog::Compute::HP::Error => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
      end

      private

      def get_server_data(servers)
        s_attr = []
        servers.map { |s| s_attr << { :id => s.id,
                                      :name => s.name,
                                      :flavor => s.flavor_id,
                                      :image => s.image_id,
                                      :public_ip => s.public_ip_address,
                                      :private_ip => s.private_ip_address,
                                      :keyname => s.key_name,
                                      :security_groups => s.security_groups.map {|sg| sg["name"]}.join(', '),
                                      :created => s.created_at,
                                      :state => s.state
                                      #:metadata => s.metadata.map {|m| "#{m.key} => #{m.value}"}.join(', ')
                                    }
                    }
        s_attr
      end

    end
  end
end
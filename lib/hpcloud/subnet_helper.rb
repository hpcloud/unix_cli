module HP
  module Cloud
    class SubnetHelper < BaseHelper
      attr_accessor :id, :name, :tenant_id
      attr_accessor :network_id, :cidr, :ip_version, :dns_nameservers
      attr_accessor :allocation_pools, :host_routes, :gateway_ip, :enable_dhcp
    
      def self.get_keys()
        return [ "id", "name", "network_id", "cidr", "ip_version", "dns_nameservers", "allocation_pools", "host_routes", "gateway_ip", "enable_dhcp" ]
      end

      def initialize(connection, foggy = nil)
        super(connection, foggy)
        if foggy.nil?
          return
        end
        @id = foggy.id
        @name = foggy.name
        @tenant_id = foggy.tenant_id
        @network_id = foggy.network_id
        @cidr = foggy.cidr
        @ip_version = foggy.ip_version
        @dns_nameservers = foggy.dns_nameservers
        @allocation_pools = foggy.allocation_pools
        @host_routes = foggy.host_routes
        @gateway_ip = foggy.gateway_ip
        @enable_dhcp = foggy.enable_dhcp
      end

      def save
        return false if is_valid? == false
        hsh = {
            :name => @name,
            :tenant_id => @tenant_id,
            :network_id => @network_id,
            :cidr => @cidr,
            :ip_version => @ip_version,
            :dns_nameservers => @dns_nameservers,
            :allocation_pools => @allocation_pools,
            :host_routes => @host_routes,
            :gateway_ip => @gateway_ip,
            :enable_dhcp => @enable_dhcp.to_s
          }
        if @fog.nil?
          response = @connection.network.create_subnet(hsh)
          if response.nil?
            set_error("Error creating subnet '#{@name}'")
            return false
          end
          @id = response.body["subnet"]["id"]
          @foggy = response.body["subnet"]
        else
          response = @connection.network.update_subnet(@id, hsh)
          if response.nil?
            set_error("Error creating subnet '#{@name}'")
            return false
          end
        end
        return true
      end

      def destroy
        @connection.network.delete_subnet(@id)
      end
    end
  end
end

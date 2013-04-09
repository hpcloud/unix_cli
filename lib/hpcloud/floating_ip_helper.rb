module HP
  module Cloud
    class FloatingIpHelper < BaseHelper
      attr_accessor :id, :tenant_id
      attr_accessor :network_id, :port, :router
      attr_accessor :fixed_ip, :floating_ip
    
      def self.get_keys()
        return [ "id", "network_id", "port", "router", "fixed_ip", "floating_ip" ]
      end

      def initialize(connection, foggy = nil)
        super(connection, foggy)
        if foggy.nil?
          return
        end
        @id = foggy.id
        @tenant_id = foggy.tenant_id
        @network_id = foggy.floating_network_id
        @port = foggy.port_id
        @router = foggy.router_id
        @fixed_ip = foggy.fixed_ip_address
        @floating_ip = foggy.floating_ip_address
      end

      def set_network(value)
        if value.nil?
          netty = Networks.new.external
          if netty.nil?
            set_error("Cannot find an external network")
            return false
          end
        else
          netty = Networks.new.get(value)
        end
        unless netty.is_valid?
          set_error netty.cstatus
        end
        @network_id = netty.id
      end

      def set_port(value)
        porty = Ports.new.get(value)
        unless porty.is_valid?
          set_error porty.cstatus
        end
        @port = porty.id
      end

      def ip
        @floating_ip
      end

      def save
        return false if is_valid? == false
        hsh = {
            :tenant_id => @tenant_id,
            :floating_network_id => @network_id,
            :port_id => @port,
            :fixed_ip_address => @fixed_ip,
            :floating_ip_address => @floating_ip
          }
        if @fog.nil?
          response = @connection.network.create_floating_ip(@network_id, hsh)
          if response.nil?
            set_error("Error creating floating IP")
            return false
          end
          @id = response.body["floatingip"]["id"]
          @floating_ip = response.body["floatingip"]["floating_ip_address"]
          @foggy = response.body["floating_ip"]
        else
          set_error("Floating IP update is not supported")
          return false
        end
        return true
      end

      def destroy
        @connection.network.delete_floating_ip(@id)
      end
    end
  end
end

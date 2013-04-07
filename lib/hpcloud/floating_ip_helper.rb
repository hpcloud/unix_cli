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

      def set_fixed_ips(value)
        return true if value.nil?
        @fixed_ips = value
        begin
          @fixed = []
          value.split(';').each{ |subnet|
            ray = subnet.split(',')
            raise Exception.new("not subnet_id,ip_address") if ray.length != 2
            @fixed << { "subnet_id" => ray[0], "ip_address" => ray[1] }
          }
        rescue Exception => e
          set_error("Invalid fixed IPs '#{value}' must be semicolon separated list of subnet_id,ip_address", :incorrect_usage)
          return false
        end
        return true
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
          @id = response.body["floating_ip"]["id"]
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

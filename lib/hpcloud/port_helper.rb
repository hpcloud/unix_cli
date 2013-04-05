module HP
  module Cloud
    class PortHelper < BaseHelper
      attr_accessor :id, :name, :tenant_id
      attr_accessor :network_id, :fixed_ips, :mac_address, :status
      attr_accessor :admin_state_up, :device_id, :device_owner, :security_groups
      attr_accessor :admin_state, :groups
    
      def self.get_keys()
        return [ "id", "name", "network_id", "fixed_ips", "mac_address", "status", "admin_state", "device_id", "device_owner" ]
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
        @fixed_ips = foggy.fixed_ips
        @mac_address = foggy.mac_address
        @status = foggy.status
        @admin_state_up = foggy.admin_state_up
        @admin_state = foggy.admin_state_up ? "up" : "down"
        @device_id = foggy.device_id
        @device_owner = foggy.device_owner
        @groups = foggy.security_groups
        @security_groups = ""
        if foggy.security_groups.kind_of? Array
          @security_groups = foggy.security_groups.join(",")
        end
      end

      def set_fixed_ips(value)
        return true if value.nil?
        @ips = value
        begin
          @fixed_ips = []
          value.split(';').each{ |subnet|
            ray = subnet.split(',')
            raise Exception.new("not subnet_id,ip_address") if ray.length != 2
            @fixed_ips << { "subnet_id" => ray[0], "ip_address" => ray[1] }
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
            :name => @name,
            :tenant_id => @tenant_id,
            :network_id => @network_id,
            :fixed_ips => @fixed_ips,
            :mac_address => @mac_address,
            :admin_state_up => @admin_state_up,
            :device_id => @device_id,
            :device_owner => @device_owner,
            :security_groups => @groups
          }
        if @fog.nil?
          response = @connection.network.create_port(@network_id, hsh)
          if response.nil?
            set_error("Error creating port '#{@name}'")
            return false
          end
          @id = response.body["port"]["id"]
          @foggy = response.body["port"]
        else
          response = @connection.network.update_port(@id, hsh)
          if response.nil?
            set_error("Error updating port '#{@name}'")
            return false
          end
        end
        return true
      end

      def destroy
        @connection.network.delete_port(@id)
      end
    end
  end
end

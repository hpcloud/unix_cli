module HP
  module Cloud
    class RouterHelper < BaseHelper
      attr_accessor :id, :name, :tenant_id
      attr_accessor :external_gateway_info, :admin_state_up, :status
      attr_accessor :gateway, :admin_state
    
      def self.get_keys()
        return [ "id", "name", "admin_state", "status", "gateway" ]
      end

      def initialize(connection, foggy = nil)
        super(connection, foggy)
        if foggy.nil?
          return
        end
        @id = foggy.id
        @name = foggy.name
        @tenant_id = foggy.tenant_id
        @external_gateway_info = foggy.external_gateway_info
        @gateway = ""
        unless foggy.external_gateway_info.nil?
          foggy.external_gateway_info.each { |k,v|
            @gateway += "," unless @gateway.empty?
            @gateway += v
          }
        end
        @admin_state_up = foggy.admin_state_up
        @admin_state = foggy.admin_state_up ? "up" : "down"
        @status = foggy.status
      end

      def set_gateway(value)
        require 'ipaddr'
        @gateway = value
        @external_gateway_info = {}
        begin
          network = Networks.new.get(@gateway)
          unless network.is_valid?
            set_error("Invalid gateway value '#{value}' must be a valid external network", :incorrect_usage)
            return false
          end
          @gateway = network.id
          @external_gateway_info = { 'network_id' => @gateway }
        rescue Exception => e
          set_error("Invalid gateway value #{value}", :incorrect_usage)
          return false
        end
        return true
      end

      def save
        return false if is_valid? == false
        hsh = {
            :name => @name,
            :tenant_id => @tenant_id,
            :external_gateway_info => @external_gateway_info,
            :admin_state_up => @admin_state_up
          }
        if @fog.nil?
          response = @connection.network.create_router(hsh)
          if response.nil?
            set_error("Error creating router '#{@name}'")
            return false
          end
          @id = response.body["router"]["id"]
          @status = response.body["router"]["status"]
          @foggy = response.body["router"]
        else
          response = @connection.network.update_router(@id, hsh)
          if response.nil?
            set_error("Error updating router '#{@name}'")
            return false
          end
        end
        return true
      end

      def destroy
        @connection.network.delete_router(@id)
      end
    end
  end
end

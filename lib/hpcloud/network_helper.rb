module HP
  module Cloud
    class NetworkHelper < BaseHelper
      attr_accessor :id, :name, :tenant_id, :status, :subnets
      attr_accessor :shared, :admin_state_up
    
      def self.get_keys()
        return [ "id", "name", "status", "shared", "admin_state_up", "subnets" ]
      end

      def initialize(connection, foggy = nil)
        super(connection, foggy)
        @shared = false
        @admin_state_up = true
        if foggy.nil?
          return
        end
        @id = foggy.id
        @name = foggy.name
        @tenant_id = foggy.tenant_id
        @status = foggy.status
        @shared = foggy.shared
        @admin_state_up = foggy.admin_state_up
        @subnets = foggy.subnets
      end

      def save
        return false if is_valid? == false
        hsh = {:name => @name,
           :tenant_id => @tenant_id,
           :shared => @shared.to_s,
           :admin_state_up => @admin_state_up.to_s}
        if @fog.nil?
          response = @connection.network.create_network(hsh)
          if response.nil?
            set_error("Error creating network '#{@name}'")
            return false
          end
          @id = response.body["network"]["id"]
          @status = response.body["network"]["status"]
          @foggy = response.body["network"]
        else
          response = @connection.network.update_network(@id, hsh)
          if response.nil?
            set_error("Error creating network '#{@name}'")
            return false
          end
        end
        return true
      end

      def destroy
        @connection.network.delete_network(@id)
      end
    end
  end
end

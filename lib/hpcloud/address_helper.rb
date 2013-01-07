module HP
  module Cloud
    class AddressHelper < BaseHelper
      attr_accessor :id, :ip, :fixed_ip, :instance_id
    
      def self.get_keys()
        return [ "id", "ip", "fixed_ip", "instance_id" ]
      end

      def initialize(connection, foggy = nil)
        super(connection, foggy)
        return if foggy.nil?
        @id = foggy.id
        @ip = foggy.ip
        @fixed_ip = foggy.fixed_ip
        @instance_id = foggy.instance_id
      end

      def save
        return false if is_valid? == false
        if @fog.nil?
          address = @connection.compute.addresses.create
          if address.nil?
            set_error("Error creating ip address")
            return false
          end
          @id = address.id
          @ip = address.ip
          @fixed_ip = address.fixed_ip
          @fog = address
          return true
        else
          raise "Update not implemented"
        end
      end

      def name=(value)
        ip = value
      end
    end
  end
end

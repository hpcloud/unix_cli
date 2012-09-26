module HP
  module Cloud
    class AddressHelper
      attr_accessor :error_string, :error_code, :fog
      attr_accessor :id, :ip, :fixed_ip, :instance_id
    
      def self.get_keys()
        return [ "id", "ip", "fixed_ip", "instance_id" ]
      end

      def initialize(connection, address = nil)
        @connection = connection
        @error_string = nil
        @error_code = nil
        @fog = address
        return if address.nil?
        @id = address.id
        @ip = address.ip
        @fixed_ip = address.fixed_ip
        @instance_id = address.instance_id
      end

      def to_hash
        hash = {}
        instance_variables.each {|var| hash[var.to_s.delete("@")] = instance_variable_get(var) }
        hash
      end

      def save
        return false if is_valid? == false
        if @fog.nil?
          address = @connection.compute.addresses.create
          if address.nil?
            @error_string = "Error creating ip address"
            @error_code = :general_error
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

      def is_valid?
        return @error_string.nil?
      end

      def destroy
        @fog.destroy unless @fog.nil?
      end
    end
  end
end

module HP
  module Cloud
    class FlavorHelper
      attr_accessor :error_string, :error_code, :fog
      attr_accessor :id, :name, :fullname, :ram, :disk
    
      def self.get_keys()
        return [ "id", "name", "ram", "disk" ]
      end

      def initialize(connection, flavor = nil)
        @connection = connection
        @error_string = nil
        @error_code = nil
        @fog = flavor
        return if flavor.nil?
        @id = flavor.id
        @name = flavor.name.gsub(/standard\./,'')
        @fullname = flavor.name
        @ram = flavor.ram
        @disk = flavor.disk
      end

      def to_hash
        hash = {}
        instance_variables.each {|var| hash[var.to_s.delete("@")] = instance_variable_get(var) }
        hash
      end

      def save
        @error_string = "Save of flavors not supported at this time"
        @error_code = :general_error
        return false
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

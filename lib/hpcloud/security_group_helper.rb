module HP
  module Cloud
    class SecurityGroupHelper
      attr_accessor :error_string, :error_code, :fog
      attr_accessor :id, :name, :description
    
      def self.get_keys()
        return [ "id", "name", "description" ]
      end

      def initialize(connection, security_group = nil)
        @connection = connection
        @error_string = nil
        @error_code = nil
        @fog = security_group
        return if security_group.nil?
        @id = security_group.id
        @name = security_group.name
        @description = security_group.description
      end

      def to_hash
        hash = {}
        instance_variables.each {|var| hash[var.to_s.delete("@")] = instance_variable_get(var) }
        hash
      end

      def save
        return false if is_valid? == false
        if @fog.nil?
          hsh = {:name => @name, :description => @description}
          security_group = @connection.compute.security_groups.new(hsh)
          if security_group.nil?
            @error_string = "Error creating ip security group"
            @error_code = :general_error
            return false
          end
          security_group.save
          @fog = security_group
          @id = security_group.id
          return true
        else
          raise "Update not implemented"
        end
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

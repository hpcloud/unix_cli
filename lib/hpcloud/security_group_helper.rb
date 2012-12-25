module HP
  module Cloud
    class SecurityGroupHelper < BaseHelper
      attr_accessor :id, :name, :description
    
      def self.get_keys()
        return [ "id", "name", "description" ]
      end

      def initialize(connection, foggy = nil)
        super(connection, foggy)
        return if foggy.nil?
        @id = foggy.id
        @name = foggy.name
        @description = foggy.description
      end

      def save
        return false if is_valid? == false
        if @fog.nil?
          hsh = {:name => @name, :description => @description}
          security_group = @connection.compute.security_groups.new(hsh)
          if security_group.nil?
            set_error("Error creating security group")
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
    end
  end
end

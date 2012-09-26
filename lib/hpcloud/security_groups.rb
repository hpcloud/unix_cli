require 'hpcloud/fog_collection'

module HP
  module Cloud
    class SecurityGroups < FogCollection
      def initialize()
        super("security group")
        @items = @connection.compute.security_groups
      end

      def create(item = nil)
        return SecurityGroupHelper.new(@connection, item)
      end
    end
  end
end

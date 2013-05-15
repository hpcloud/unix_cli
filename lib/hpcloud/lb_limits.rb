require 'hpcloud/fog_collection'

module HP
  module Cloud
    class LbLimits < FogCollection
      def initialize
        super("lb limits")
        @items = @connection.lb.limits
      end

      def create(item = nil)
        return item
      end
    end
  end
end

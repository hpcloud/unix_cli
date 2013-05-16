require 'hpcloud/fog_collection'

module HP
  module Cloud
    class LbLimits < FogCollection
      def initialize
        super("load balancer limit")
        @items = @connection.lb.limits
      end

      def matches(arg, item)
        return true
      end
    end
  end
end

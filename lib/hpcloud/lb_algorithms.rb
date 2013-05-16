require 'hpcloud/fog_collection'

module HP
  module Cloud
    class LbAlgorithms < FogCollection
      def initialize
        super("load balancer algorithm")
        @items = @connection.lb.algorithms
      end

      def matches(arg, item)
        return (arg == item.name.to_s)
      end
    end
  end
end

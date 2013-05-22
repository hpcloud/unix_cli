require 'hpcloud/fog_collection'

module HP
  module Cloud
    class LbProtocols < FogCollection
      def initialize
        super("load balancer protocol")
        @items = @connection.lb.protocols
      end

      def matches(arg, item)
        return (arg == item.name.to_s)
      end
    end
  end
end

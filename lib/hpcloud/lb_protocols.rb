require 'hpcloud/fog_collection'

module HP
  module Cloud
    class LbProtocols < FogCollection
      def initialize
        super("load balancer protocol")
        @items = @connection.lb.protocols
      end
    end
  end
end

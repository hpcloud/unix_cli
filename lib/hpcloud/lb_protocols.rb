require 'hpcloud/fog_collection'

module HP
  module Cloud
    class LbProtocols < FogCollection
      def initialize
        super("lb protocols")
        @items = @connection.lb.protocols
      end

      def create(item = nil)
        return item
      end
    end
  end
end

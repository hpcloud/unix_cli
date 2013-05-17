require 'hpcloud/fog_collection'

module HP
  module Cloud
    class LbNodes < FogCollection
      def initialize(id)
        super("load balancer node")
        @items = @connection.lb.nodes.get(id)
      end

      def unique(name)
        super(name)
        Fog::HP::LB::Node.new({:service => Connection.instance.lb})
      end
    end
  end
end

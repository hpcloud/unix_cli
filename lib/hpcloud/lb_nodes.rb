require 'hpcloud/fog_collection'

module HP
  module Cloud
    class LbNodes < FogCollection
      def initialize(parent_id)
        super("load balancer node")
        @items = @connection.lb.nodes({:parent_id => parent_id})
      end

      def unique(name)
        super(name)
        Fog::HP::LB::Node.new({:service => Connection.instance.lb})
      end
    end
  end
end

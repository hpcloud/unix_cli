require 'hpcloud/fog_collection'

module HP
  module Cloud
    class LbNodes < FogCollection
      def initialize(load_balancer_id)
        super("load balancer node")
        @items = @connection.lb.nodes({:load_balancer_id => load_balancer_id})
      end

      def unique(name)
        super(name)
        Fog::HP::LB::Node.new({:service => Connection.instance.lb})
      end

      def matches(arg, item)
        return ((arg == item.id.to_s) || (arg == "#{item.address}:#{item.port}"))
      end
    end
  end
end
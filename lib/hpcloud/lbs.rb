require 'hpcloud/fog_collection'

module HP
  module Cloud
    class Lbs < FogCollection
      def initialize
        super("load balancer")
        @items = @connection.lb.load_balancers
      end

      def unique(name)
        super(name)
        Fog::HP::LB::LoadBalancer.new({:service => Connection.instance.lb})
      end
    end
  end
end

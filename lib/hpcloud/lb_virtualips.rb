require 'hpcloud/fog_collection'

module HP
  module Cloud
    class LbVirtualIps < FogCollection
      def initialize(load_balancer_id)
        super("load balancer virtual IPs")
        @items = @connection.lb.virtual_ips({:load_balancer_id => load_balancer_id})
      end

      def unique(name)
        super(name) 
        Fog::HP::LB::VirtualIps.new({:service => Connection.instance.lb})
      end

      def matches(arg, item)
        return ((arg == item.id.to_s) || (arg == item.address.to_s))
      end
    end
  end
end

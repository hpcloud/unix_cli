require 'hpcloud/fog_collection'

module HP
  module Cloud
    class Routers < FogCollection
      def initialize
        super("router")
        @items = @connection.network.routers
      end

      def unique(name)
        super(name)
        Fog::HP::Network::Router.new({:service => Connection.instance.network})
      end

      def self.parse_gateway(value)
        networks = Networks.new
        unless value.nil?
          unless value.empty?
            netty = networks.get(value)
            return netty
          end
          return {}
        end
        networks.items.each{ |x|
          if x.router_external == true
            return x
          end
        }
        raise HP::Cloud::Exceptions::General.new("Cannot find external network to use as gateway")
      end

    end
  end
end

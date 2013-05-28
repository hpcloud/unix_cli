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
            return { 'network_id' => networks.get(value).id }
          end
          return {}
        end
        networks.items.each{ |x|
          if x.router_external == true
            return { 'network_id' => x.id }
          end
        }
        raise HP::Cloud::Exceptions::General.new("Cannot find external network to use as gateway")
      end

    end
  end
end

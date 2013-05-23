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


    end
  end
end

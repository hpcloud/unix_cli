require 'hpcloud/fog_collection'
require 'hpcloud/router_helper'

module HP
  module Cloud
    class Routers < FogCollection
      def initialize
        super("router")
        @items = @connection.network.routers
      end

      def create(item = nil)
        return RouterHelper.new(@connection, item)
      end
    end
  end
end

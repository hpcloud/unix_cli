require 'hpcloud/fog_collection'
require 'hpcloud/network_helper'

module HP
  module Cloud
    class Networks < FogCollection
      def initialize
        super("network")
        @items = @connection.network.networks
      end

      def create(item = nil)
        return NetworkHelper.new(@connection, item)
      end
    end
  end
end

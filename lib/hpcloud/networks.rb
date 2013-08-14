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

      def external
        @items.each{ |n|
          if n.router_external == true
            return create(n)
          end
        }
        return nil
      end
    end
  end
end

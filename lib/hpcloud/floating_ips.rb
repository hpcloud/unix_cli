require 'hpcloud/fog_collection'
require 'hpcloud/port_helper'

module HP
  module Cloud
    class FloatingIps < FogCollection
      def initialize
        super("port")
        @items = @connection.network.floating_ips
      end

      def create(item = nil)
        return FloatingIpHelper.new(@connection, item)
      end
    end
  end
end

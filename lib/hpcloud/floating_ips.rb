require 'hpcloud/fog_collection'
require 'hpcloud/port_helper'

module HP
  module Cloud
    class FloatingIps < FogCollection
      def initialize
        super("ip address" "an")
        @items = @connection.network.floating_ips
      end

      def create(item = nil)
        return FloatingIpHelper.new(@connection, item)
      end

      def matches(arg, item)
        return ((arg == item.id.to_s) || (arg == item.ip.to_s))
      end
    end
  end
end

require 'hpcloud/fog_collection'
require 'hpcloud/address_helper'

module HP
  module Cloud
    class Addresses < FogCollection
      def initialize()
        super("ip address", "an")
        @items = @connection.compute.addresses
      end

      def create(item = nil)
        return AddressHelper.new(@connection, item)
      end

      def matches(arg, item)
        return ((arg == item.id.to_s) || (arg == item.ip.to_s))
      end
    end
  end
end

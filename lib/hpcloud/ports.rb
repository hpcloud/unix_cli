require 'hpcloud/fog_collection'
require 'hpcloud/port_helper'

module HP
  module Cloud
    class Ports < FogCollection
      def initialize
        super("port")
        @items = @connection.network.ports
      end

      def create(item = nil)
        return PortHelper.new(@connection, item)
      end
    end
  end
end

require 'hpcloud/fog_collection'
require 'hpcloud/server_helper'

module HP
  module Cloud
    class Servers < FogCollection
      def initialize(connection = nil)
        super("server", connection)
        @items = @connection.compute.servers
      end

      def create(item = nil)
        return ServerHelper.new(@connection.compute, item)
      end
    end
  end
end
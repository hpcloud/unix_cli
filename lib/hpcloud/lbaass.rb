require 'hpcloud/fog_collection'
require 'hpcloud/lbaas_helper'

module HP
  module Cloud
    class Lbaass < FogCollection
      def initialize
        super("lbaas")
        @items = @connection.lbaas
      end

      def create(item = nil)
        return LbaasHelper.new(@connection, item)
      end
    end
  end
end

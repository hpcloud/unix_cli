require 'hpcloud/fog_collection'
require 'hpcloud/subnet_helper'

module HP
  module Cloud
    class Subnets < FogCollection
      def initialize
        super("subnet")
        @items = @connection.network.subnets
      end

      def create(item = nil)
        return SubnetHelper.new(@connection, item)
      end
    end
  end
end

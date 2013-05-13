require 'hpcloud/fog_collection'
require 'hpcloud/lb_helper'

module HP
  module Cloud
    class LbAlgorithms < FogCollection
      def initialize
        super("lb algorithms")
        @items = @connection.lb.algorithms
      end

      def create(item = nil)
        return item
      end
    end
  end
end

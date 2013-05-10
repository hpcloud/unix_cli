require 'hpcloud/fog_collection'
require 'hpcloud/lb_helper'

module HP
  module Cloud
    class Lbs < FogCollection
      def initialize
        super("lb")
        @items = @connection.lb.list_load_balancers.body["domains"]
      end

      def create(item = nil)
        return LbHelper.new(@connection, item)
      end
    end
  end
end

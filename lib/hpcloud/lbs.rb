require 'hpcloud/fog_collection'

module HP
  module Cloud
    class Lbs < FogCollection
      def initialize
        super("load balancer")
        @items = @connection.lb.load_balancers
      end
    end
  end
end

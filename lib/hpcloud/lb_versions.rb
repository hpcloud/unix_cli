require 'hpcloud/fog_collection'

module HP
  module Cloud
    class LbVersions < FogCollection
      def initialize
        super("load balancer version")
        @items = @connection.lb.versions
      end

      def matches(arg, item)
        return true
      end
    end
  end
end

require 'hpcloud/fog_collection'

module HP
  module Cloud
    class Flavors < FogCollection
      def initialize()
        super("flavor")
        @items = @connection.compute.flavors
      end

      def create(item = nil)
        return FlavorHelper.new(@connection, item)
      end

      def matches(arg, item)
        return ((arg == item.id.to_s) || (arg == item.name.to_s) || (arg == item.fullname.to_s))
      end
    end
  end
end

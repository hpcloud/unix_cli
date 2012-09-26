require 'hpcloud/fog_collection'

module HP
  module Cloud
    class Keypairs < FogCollection
      def initialize()
        super("keypair")
        @items = @connection.compute.key_pairs
      end

      def create(item = nil)
        return KeypairHelper.new(@connection, item)
      end

      def matches(arg, item)
        return (arg == item.name.to_s)
      end
    end
  end
end

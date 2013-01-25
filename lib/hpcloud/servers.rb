require 'hpcloud/fog_collection'
require 'hpcloud/server_helper'

module HP
  module Cloud
    class Servers < FogCollection
      def initialize
        super("server")
        @items = @connection.compute.servers
      end

      def create(item = nil)
        return ServerHelper.new(@connection.compute, item)
      end

      def find_by_ip(ipaddy)
        @items.each { |x| 
          if ipaddy == x.public_ip_address
            return create(x)
          end
        }
        return nil
      end
    end
  end
end

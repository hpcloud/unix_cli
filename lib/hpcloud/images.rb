require 'hpcloud/image_helper'

module HP
  module Cloud
    class Images < FogCollection
      def initialize() 
        super("image")
        @items = @connection.compute.images
      end
      
      def create(item = nil)
        return ImageHelper.new(item)
      end
    end
  end
end

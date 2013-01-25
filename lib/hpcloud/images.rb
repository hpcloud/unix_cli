require 'hpcloud/fog_collection'
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

      def matches(arg, item)
        return (arg == item.id.to_s) if arg.match(/^[0-9]+$/)
        return ((arg == item.id.to_s) || (item.name.to_s.match(arg)))
      end
    end
  end
end

require 'hpcloud/fog_collection'
require 'hpcloud/volume_helper'

module HP
  module Cloud
    class Volumes < FogCollection
      def initialize
        super("volume")
        @items = @connection.block.volumes
      end

      def create(item = nil)
        return VolumeHelper.new(@connection, item)
      end
    end
  end
end

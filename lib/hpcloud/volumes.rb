require 'hpcloud/fog_collection'
require 'hpcloud/volume_helper'

module HP
  module Cloud
    class Volumes < FogCollection
      def initialize(bootable=false)
        super("volume")
        if bootable
          @items = @connection.block.volumes.all(:only_bootable => true)
        else
          @items = @connection.block.volumes
        end
      end

      def create(item = nil)
        return VolumeHelper.new(@connection, item)
      end
    end
  end
end

require 'hpcloud/fog_collection'
require 'hpcloud/snapshot_helper'

module HP
  module Cloud
    class Snapshots < FogCollection
      def initialize()
        super("snapshot")
        @items = @connection.block.snapshots
      end

      def create(item = nil)
        return SnapshotHelper.new(@connection, item)
      end
    end
  end
end

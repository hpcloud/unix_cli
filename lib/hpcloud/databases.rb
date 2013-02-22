require 'hpcloud/fog_collection'
require 'hpcloud/database_helper'

module HP
  module Cloud
    class Databases < FogCollection
      def initialize
        super("database")
        @items = @connection.block.databases
      end

      def create(item = nil)
        return DatabaseHelper.new(@connection, item)
      end
    end
  end
end

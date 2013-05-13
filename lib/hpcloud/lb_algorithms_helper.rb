module HP
  module Cloud
    class LbAlgorithmsHelper < BaseHelper
      attr_accessor :id, :name
    
      def self.get_keys()
        return [ "name" ]
      end

      def initialize(connection, foggy = nil)
        super(connection, foggy)
        return if foggy.nil?
        @id = foggy.name
        @name = foggy.name
      end

      def save
        raise Exception.new("Not implemented")
      end

      def destroy
        raise Exception.new("Not implemented")
      end
    end
  end
end

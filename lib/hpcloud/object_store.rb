require 'hpcloud/resource.rb'

module HP
  module Cloud
    class ObjectStore < Resource
      def valid_destination(source)
        return false
      end

      def foreach(&block)
        containers = @storage.directories
        containers.each { |x|
          yield Resource.create(@storage, ':' + x.key)
        }
      end
    end
  end
end

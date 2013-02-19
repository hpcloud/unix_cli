module HP
  module Cloud
    class ObjectStore < Resource
      def valid_destination(source)
        return false
      end

      def foreach(&block)
        containers = @storage.directories
        containers.each { |x|
          res = ResourceFactory.create(@storage, ':' + x.key)
          res.size = x.bytes
          res.count = x.count
          yield res
        }
      end

      def is_container?
        true # container of containers
      end
    end
  end
end

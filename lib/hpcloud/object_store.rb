module HP
  module Cloud
    class ObjectStore < Resource
      def valid_destination(source)
        return false
      end

      def foreach(&block)
        containers = @storage.directories
        containers.each { |x|
          yield ResourceFactory.create(@storage, ':' + x.key)
        }
      end

      def is_container?
        true # container of containers
      end
    end
  end
end

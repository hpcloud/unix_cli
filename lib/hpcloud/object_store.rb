module HP
  module Cloud
    class ObjectStore < Resource
      def valid_destination(source)
        return false
      end

      def foreach(&block)
        if @@limit.nil?
          @@limit = Config.new.get_i(:storage_page_length, 10000)
        end
        total = 0
        count = 0
        marker = nil
        begin
          options = { :limit => @@limit, :marker => marker}
          begin
            result = @storage.get_containers(options)
          rescue NoMethodError => e
            result = @storage.directories.each { |container|
              yield ResourceFactory.create(@storage, ':' + container.key)
            }
            return
          end
          total = result.headers['X-Account-Container-Count'].to_i
	  lode = result.body.length
	  count += lode
          result.body.each { |x|
            name = x['name']
            res = ResourceFactory.create(@storage, ':' + name)
            res.size = x['bytes']
            res.count = x['count']
            yield res
            marker = name
          }
          break if lode < @@limit
        end until count >= total
      end

      def is_container?
        true # container of containers
      end
    end
  end
end

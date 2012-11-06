module HP
  module Cloud
    class SharedResource < RemoteResource
      def get_container
        return true
      end

      def get_size()
        begin
          head = @storage.head_shared_object(@fname)
          return 0 if head.nil?
          return 0 if head.headers["Content-Length"].nil?
          return head.headers["Content-Length"].to_i
        rescue
          return 0
        end
      end

      def foreach(&block)
        yield self
      end

      def read
        begin
          @storage.get_shared_object(@fname) { |chunk|
            yield chunk
          }
        rescue Fog::Storage::HP::NotFound => e
          @error_string = "The specified object does not exist."
          @error_code = :not_found
          result = false
        end
      end
    end
  end
end

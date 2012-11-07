module HP
  module Cloud
    class SharedResource < RemoteResource
      def parse()
        @container = nil
        @path = nil
        if @fname.empty?
          return
        end
        @container = @fname.match(/http[s]*:\/\/[^\/]*\/[^\/]*\/[^\/]*\/[^\/]*/).to_s
        @path = @fname.gsub(@container + '/', '')
        @path = "/" if @path.empty?
      end

      def get_container
        begin
          return false if is_valid? == nil
          return true unless @directory.nil?

          @directory = @storage.shared_directories.get(@container)
          if @directory.nil?
            @error_string = "Cannot find container '#{@container}'."
            @error_code = :not_found
            return false
          end
        rescue Excon::Errors::Forbidden => e
          resp = ErrorResponse.new(e)
          @error_string  = resp.error_string
          @error_code = :permission_denied
          return false
        rescue Fog::HP::Errors::Forbidden => error
          @error_string  = "Permission denied trying to access '#{@fname}'."
          @error_code = :permission_denied
          return false
        rescue Exception => error
          @error_string = "Error reading '#{@fname}': " + error.to_s
          @error_code = :general_error
          return false
        end
        return true
      end

      def get_size()
        begin
          return 0 unless get_container
          file = @directory.files.get(@path)
          return 0 if file.nil?
          return file.content_length
        rescue Exception => e
        end
        return 0
      end

      def foreach(&block)
        return false if get_container == false
        return if @directory.nil?
        case @ftype
        when :shared_directory
          regex = "^" + path + ".*"
        else
          regex = "^" + path + '$'
        end
        @directory.files.each { |x|
          name = x.key.to_s
          if ! name.match(regex).nil?
            yield ResourceFactory.create(@storage, container + '/' + name)
          end
        }
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

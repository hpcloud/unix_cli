module HP
  module Cloud
    class SharedResource < RemoteResource
      attr_accessor :count

      def parse()
        @container = nil
        @path = nil
        if @fname.empty?
          return
        end
        #
        # Extract container given the expected input in the form:
        # https://domain_and_port/version/tenant_id/container/object/name/with/slashes.txt
        # where the container for that shared object is:
        # https://domain_and_port/version/tenant_id/container
        # and the path for the object is:
        # object/name/with/slashes.txt
        @container = @fname.match(/http[s]*:\/\/[^\/]*\/[^\/]*\/[^\/]*\/[^\/]*/).to_s
        @path = @fname.gsub(@container, '')
        @path = @path.gsub(/^\/*/, '')
        @lname = @fname
        @sname = @path
      end

      def head
        return container_head()
      end

      def container_head
        begin
          return true unless @size.nil?
          @size = 0
          @directory = @storage.shared_directories.get(@container)
          if @directory.nil?
            @cstatus = CliStatus.new("Cannot find container '#{@container}'.", :not_found)
            return false
          end
          @count = @directory.count.to_i
          @size = @directory.bytes.to_i
        rescue Fog::Storage::HP::NotFound => error
p self
          @cstatus = CliStatus.new("Cannot find container '#{@container}'.", :not_found)
          return false
        rescue Excon::Errors::Forbidden => e
          resp = ErrorResponse.new(e)
          @cstatus  = CliStatus.new(resp.error_string, :permission_denied)
          return false
        rescue Fog::HP::Errors::Forbidden => error
          @cstatus  = CliStatus.new("Permission denied trying to access '#{@fname}'.", :permission_denied)
          return false
        rescue Exception => error
          @cstatus = CliStatus.new("Error reading '#{@fname}': " + error.to_s, :general_error)
          return false
        end
        return true
      end

      def object_head
        return container_head()
      end

      def get_size()
        return 0 unless container_head()
        return @size
      end

      #
      # Add the capability to iterate through all the matching files
      # for copy.  Use different regular expressions for a directory
      # where we want to recursively copy things vs a regular file
      #
      def foreach(&block)
        return false unless container_head()
        case @ftype
        when :shared_directory
          regex = "^" + path + ".*"
        else
          regex = "^" + path + '$'
        end
        @directory.files.each { |x|
          name = x.key.to_s
          if ! name.match(regex).nil?
            yield ResourceFactory.create(@storage, @container + '/' + name)
          end
        }
      end

      def read
        begin
          @storage.get_shared_object(@fname) { |chunk, one, two|
            yield chunk
          }
        rescue Fog::Storage::HP::NotFound => e
          @cstatus = CliStatus.new("The specified object does not exist.", :not_found)
          result = false
        end
      end

      def copy_file(from)
        result = true
        if from.isLocal()
          return false unless from.open
          options = { 'Content-Type' => from.get_mime_type() }
          @storage.put_shared_object(@container, @destination, {}, options) {
            from.read().to_s
          }
          result = false unless from.close()
        else
          begin
            @storage.put_shared_object(@container, @destination, nil, {'X-Copy-From' => "/#{from.container}/#{from.path}" })
          rescue Fog::Storage::HP::NotFound => e
            @cstatus = CliStatus.new("The specified object does not exist.", :not_found)
            result = false
          end
        end
        return result
      end

      def remove(force, at=nil, after=nil)
        unless at.nil?
          @cstatus = CliStatus.new("The at option is only supported for objects.", :incorrect_usage)
          return false
        end
        unless after.nil?
          @cstatus = CliStatus.new("The after option is only supported for objects.", :incorrect_usage)
          return false
        end

        if @path.empty?
          @cstatus = CliStatus.new("Removal of shared containers is not supported.", :not_supported)
          return false
        end
        begin
          return false unless container_head()
          @storage.delete_shared_object(@container + '/' + @path)
        rescue Fog::Storage::HP::NotFound => error
          @cstatus = CliStatus.new("You don't have an object named '#{@fname}'.", :not_found)
          return false
        rescue Excon::Errors::Forbidden => error
          @cstatus = CliStatus.new("Permission denied for '#{@fname}.", :permission_denied)
          return false
        rescue Exception => e
          @cstatus = CliStatus.new("Exception removing '#{@fname}': " + e.to_s, :general_error)
          return false
        end
        return true
      end
    end
  end
end

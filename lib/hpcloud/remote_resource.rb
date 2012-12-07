module HP
  module Cloud
    class RemoteResource < Resource

      def parse
        super
        
        unless @fname.index('<').nil?
          raise Exception.new("Valid object names do not contain the '<' character: #{@fname}")
        end
        unless @fname.index('>').nil?
          raise Exception.new("Valid object names do not contain the '>' character: #{@fname}")
        end
        unless @fname.index('"').nil?
          raise Exception.new("Valid object names do not contain the '\"' character: #{@fname}")
        end
      end

      def get_size()
        begin
          head = @storage.head_object(@container, @path)
          return 0 if head.nil?
          return 0 if head.headers["Content-Length"].nil?
          return head.headers["Content-Length"].to_i
        rescue
          return 0
        end
      end

      def get_container
        begin
          return false if is_valid? == nil

          @directory = @storage.directories.get(@container)
          if @directory.nil?
            @error_string = "Cannot find container ':#{@container}'."
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

      def get_files
        begin
          return false if is_valid? == nil

          unless @path.empty?
            @file = @directory.files.get(@path)
            if @file.nil?
              @error_string = "Cannot find object '#{@fname}'."
              @error_code = :not_found
              return false
            end
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

      def container_head()
        begin
          return nil if is_valid? == false

          @head = @storage.directories.head(@container)
          if @head.nil?
            @error_string = "Cannot find container ':#{@container}'."
            @error_code = :not_found
            return nil
          end
        rescue Excon::Errors::Forbidden => e
          resp = ErrorResponse.new(e)
          @error_string  = resp.error_string
          @error_code = :permission_denied
          return nil
        rescue Fog::HP::Errors::Forbidden => error
          @error_string  = "Permission denied trying to access '#{@fname}'."
          @error_code = :permission_denied
          return nil
        rescue Exception => error
          @error_string = "Error reading '#{@fname}': " + error.to_s
          @error_code = :general_error
          return nil
        end
        return @head
      end

      def read
        begin
          @storage.get_object(@container, @path) { |chunk, remain, tot|
            yield chunk
          }
        rescue Fog::Storage::HP::NotFound => e
          @error_string = "The specified object does not exist."
          @error_code = :not_found
          result = false
        end
      end

      def close
        return true
      end

      def read_header()
        begin
          return false if get_container == false
          return false if get_files == false

          if is_container?
            @public_url = @directory.public_url
            @cdn_public_url = @directory.cdn_public_url
            @cdn_public_ssl_url = @directory.cdn_public_ssl_url
            @public = @directory.public? ? "yes" : "no"
            @readers = @directory.list_users_with_read.join(",")
            @writers = @directory.list_users_with_write.join(",")
          else
            file = @directory.files.head(@path)
            if file.nil?
               @error_string = "Cannot find object named '#{@fname}'."
               @error_code = :not_found
               return false
            end
            @public_url = file.public_url
            @public_url = @public_url.gsub(/%2F/, '/') unless @public_url.nil?
            @cdn_public_url = file.cdn_public_url
            @cdn_public_url = @cdn_public_url.gsub(/%2F/, '/') unless @cdn_public_url.nil?
            @cdn_public_ssl_url = file.cdn_public_ssl_url
            @cdn_public_ssl_url = @cdn_public_ssl_url.gsub(/%2F/, '/') unless @cdn_public_ssl_url.nil?
            @public = @directory.public? ? "yes" : "no"
            @readers = @directory.list_users_with_read.join(",")
            @writers = @directory.list_users_with_write.join(",")
          end
        rescue Exception => error
          @error_string = "Error reading '#{@fname}': " + error.to_s
          @error_code = :general_error
          return false
        end
        return true
      end

      def valid_source()
        return valid_container()
      end

      def valid_destination(source)
        if ! valid_container()
          return false
        end
        if ((source.isMulti() == true) && (isDirectory() == false))
          @error_string = "Invalid target for directory/multi-file copy '#{@fname}'."
          @error_code = :incorrect_usage
          return false
        end
        return true
      end

      def valid_container()
        return get_container
      end

      def set_destination(name)
        if ! valid_container()
          return false
        end
        if (@path.empty?)
          @destination = name
        else
          if isObject()
            @destination = @path
          else
            @destination = @path
            @destination += '/' unless @destination.end_with?('/')
            @destination += name
          end
        end
        return true
      end

      def copy_file(from)
        result = true
        if from.isLocal()
          if (from.open() == false) then return false end
          options = { 'Content-Type' => from.get_mime_type() }
          @storage.put_object(@container, @destination, {}, options) {
            from.read().to_s
          }
          result = false if ! from.close()
        else
          begin
            @storage.put_object(@container, @destination, nil, {'X-Copy-From' => "/#{from.container}/#{from.path}" })
          rescue Fog::Storage::HP::NotFound => e
            @error_string = "The specified object does not exist."
            @error_code = :not_found
            result = false
          end
        end
        return result
      end

      def foreach(&block)
        return false if get_container == false
        return if @directory.nil?
        case @ftype
        when :container_directory
          regex = "^" + path + ".*"
        when :container
          regex = ".*"
        else
          regex = "^" + path + '$'
        end
        @directory.files.each { |x|
          name = x.key.to_s
          if ! name.match(regex).nil?
            yield ResourceFactory.create(@storage, ':' + container + '/' + name)
          end
        }
      end

      def get_destination()
        return ':' + @container.to_s + '/' + @destination.to_s
      end

      def remove(force)
        begin
          return false if get_container == false

          # container should be a class
          if is_container?
            if force == true
              @directory.files.each { |file| file.destroy }
            end
            begin
              @directory.destroy
            rescue Excon::Errors::Conflict
              @error_string = "The container '#{@fname}' is not empty. Please use -f option to force deleting a container with objects in it."
              @error_code = :conflicted
              return false
            end
          else
            file = @directory.files.head(@path)
            if file.nil?
               @error_string = "You don't have an object named '#{@fname}'."
               @error_code = :not_found
               return false
            end
            file.destroy
          end

        rescue Excon::Errors::Forbidden => error
          @error_string = "Permission denied for '#{@fname}."
          @error_code = :permission_denied
          return false
        rescue Exception => e
          @error_string = "Exception removing '#{@fname}': " + e.to_s
          @error_code = :general_error
          return false
        end
        return true
      end

      def tempurl(period)
        begin
          period = 172800 if period.nil?
          @head = container_head()
          return nil if @head.nil?

          # container should be a class
          if is_container?
             @error_string = "Temporary URLs not supported on containers ':#{@container}'."
             @error_code = :incorrect_usage
             return nil
          end

          file = @head.files.get(@path)
          if file.nil?
             @error_string = "Cannot find object named '#{@fname}'."
             @error_code = :not_found
             return nil
          end
          return file.temp_signed_url(period, "GET")
        rescue Excon::Errors::Forbidden => error
          @error_string = "Permission denied for '#{@fname}."
          @error_code = :permission_denied
          return nil
        rescue Exception => e
          @error_string = "Exception getting temporary URL for '#{@fname}': " + e.to_s
          @error_code = :general_error
          return nil
        end
        return nil
      end

      def grant(acl)
        begin
          return false if is_valid? == false
          return false if get_container == false
          return false if get_files == false

          unless is_container?
            @error_string = "ACLs are only supported on containers (e.g. :container)."
            @error_code = :not_supported
            return false
          end

          @directory.grant(acl.permissions, acl.users)
          @directory.save
          return true
        rescue Exception => e
          @error_string = "Exception granting permissions for '#{@fname}': " + e.to_s
          @error_code = :general_error
          return false
        end
      end

      def revoke(acl)
        begin
          return false if is_valid? == false
          return false if get_container == false
          return false if get_files == false

          unless is_container?
            @error_string = "ACLs are only supported on containers (e.g. :container)."
            @error_code = :not_supported
            return false
          end

          @directory.revoke(acl.permissions, acl.users)
          @directory.save
          return true
        rescue Exception => e
          @error_string = "Exception revoking permissions for '#{@fname}': " + e.to_s
          @error_code = :general_error
          return false
        end
      end
    end
  end
end

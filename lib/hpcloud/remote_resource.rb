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
            @cstatus = CliStatus.new("Cannot find container ':#{@container}'.", :not_found)
            return false
          end
        rescue Excon::Errors::Forbidden => e
          resp = ErrorResponse.new(e)
          @cstatus = CliStatus.new(resp.error_string, :permission_denied)
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

      def get_files
        begin
          return false if is_valid? == nil

          unless @path.empty?
            @file = @directory.files.get(@path)
            if @file.nil?
              @cstatus = CliStatus.new("Cannot find object '#{@fname}'.", :not_found)
              return false
            end
          end
        rescue Excon::Errors::Forbidden => e
          resp = ErrorResponse.new(e)
          @cstatus  = CliStatus.new(resp.error_string, :permission_denied)
          return false
        rescue Fog::HP::Errors::Forbidden => error
          @cstatus = CliStatus.new("Permission denied trying to access '#{@fname}'.", :permission_denied)
          return false
        rescue Exception => error
          @cstatus = CliStatus.new("Error reading '#{@fname}': " + error.to_s, :general_error)
          return false
        end
        return true
      end

      def container_head()
        begin
          return nil if is_valid? == false

          @head = @storage.directories.head(@container)
          if @head.nil?
            @cstatus = CliStatus.new("Cannot find container ':#{@container}'.", :not_found)
            return nil
          end
        rescue Excon::Errors::Forbidden => e
          resp = ErrorResponse.new(e)
          @cstatus = CliStatus.new(resp.error_string, :permission_denied)
          return nil
        rescue Fog::HP::Errors::Forbidden => error
          @cstatus = CliStatus.new("Permission denied trying to access '#{@fname}'.", :permission_denied)
          return nil
        rescue Exception => error
          @cstatus = CliStatus.new("Error reading '#{@fname}': " + error.to_s, :general_error)
          return nil
        end
        return @head
      end

      def open(output=false, siz=0)
        return true
      end

      def read
        begin
          yielded_something = false
          @storage.get_object(@container, @path) { |chunk, remain, tot|
            yield chunk
            yielded_something = true
          }
          yield '' unless yielded_something
        rescue Fog::Storage::HP::NotFound => e
          @cstatus = CliStatus.new("The specified object does not exist.", :not_found)
          result = false
        end
      end

      def write(chunk)
        if @write_io.nil?
          begin
            @read_io, @write_io = IO.pipe
            @write_thread = Thread.new {
              @storage.put_object(@container, @destination, {}, @options) {
                @read_io.read
              }
            }
          rescue Exception => e
            @cstatus = CliStatus.new("Error writing object creating thread.")
            return false
          end
        end
        begin
          @write_io.write(chunk)
        rescue Exception => e
          @cstatus = CliStatus.new("Error writing object.")
          return false
        end
        return true
      end

      def close
        @write_io.close unless @write_io.nil?
        @write_io = nil
        @write_thread.join unless @write_thread.nil?
        @write_thread = nil
        @read_io.close unless @read_io.nil?
        @read_io = nil
        @pbar.increment(@lastread) unless @pbar.nil?
        @pbar.finish unless @pbar.nil?
        @lastread = 0
        @pbar = nil

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
               @cstatus = CliStatus.new("Cannot find object named '#{@fname}'.", :not_found)
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
          @cstatus = CliStatus.new("Error reading '#{@fname}': " + error.to_s, :general_error)
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
          @cstatus = CliStatus.new("Invalid target for directory/multi-file copy '#{@fname}'.", :incorrect_usage)
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
        return false if (from.open() == false)
        if from.isLocal()
          @options = { 'Content-Type' => from.get_mime_type() }
          @storage.put_object(@container, @destination, {}, @options) {
            from.read().to_s
          }
        else
          begin
            if from.has_same_account(@storage)
              @storage.put_object(@container, @destination, nil, {'X-Copy-From' => "/#{from.container}/#{from.path}" })
            else
              @lastread = 0
              siz = from.get_size()
              @pbar = Progress.new(@destination, from.get_size())
              @options = { 'Content-Type' => from.get_mime_type() }
              from.read() { |chunk|
                if ! write(chunk)
                  result = false
                  break
                end
                @pbar.increment(@lastread) unless @pbar.nil?
                @lastread = chunk.length
              }
            end
          rescue Fog::Storage::HP::NotFound => e
            @cstatus = CliStatus.new("The specified object does not exist.", :not_found)
            result = false
          end
        end
        result = false if ! from.close()
        result = false unless close()
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
          unless name.end_with?('/')
            if ! name.match(regex).nil?
              yield ResourceFactory.create(@storage, ':' + container + '/' + name)
            end
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
              @cstatus = CliStatus.new("The container '#{@fname}' is not empty. Please use -f option to force deleting a container with objects in it.", :conflicted)
              return false
            end
          else
            file = @directory.files.head(@path)
            if file.nil?
               @cstatus = CliStatus.new("You don't have an object named '#{@fname}'.", :not_found)
               return false
            end
            file.destroy
          end

        rescue Excon::Errors::Forbidden => error
          @cstatus = CliStatus.new("Permission denied for '#{@fname}.", :permission_denied)
          return false
        rescue Exception => e
          @cstatus = CliStatus.new("Exception removing '#{@fname}': " + e.to_s, :general_error)
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
             @cstatus = CliStatus.new("Temporary URLs not supported on containers ':#{@container}'.", :incorrect_usage)
             return nil
          end

          file = @head.files.get(@path)
          if file.nil?
             @cstatus = CliStatus.new("Cannot find object named '#{@fname}'.", :not_found)
             return nil
          end
          return file.temp_signed_url(period, "GET")
        rescue Excon::Errors::Forbidden => error
          @cstatus = CliStatus.new("Permission denied for '#{@fname}.", :permission_denied)
          return nil
        rescue Exception => e
          @cstatus = CliStatus.new("Exception getting temporary URL for '#{@fname}': " + e.to_s, :general_error)
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
            @cstatus = CliStatus.new("ACLs are only supported on containers (e.g. :container).", :not_supported)
            return false
          end

          @directory.grant(acl.permissions, acl.users)
          @directory.save
          return true
        rescue Exception => e
          @cstatus = CliStatus.new("Exception granting permissions for '#{@fname}': " + e.to_s, :general_error)
          return false
        end
      end

      def revoke(acl)
        begin
          return false if is_valid? == false
          return false if get_container == false
          return false if get_files == false

          unless is_container?
            @cstatus = CliStatus.new("ACLs are only supported on containers (e.g. :container).", :not_supported)
            return false
          end

          @directory.revoke(acl.permissions, acl.users)
          @directory.save
          return true
        rescue Exception => e
          @cstatus = CliStatus.new("Exception revoking permissions for '#{@fname}': " + e.to_s, :general_error)
          return false
        end
      end

      def has_same_account(storage)
        return storage == @storage
      end
    end
  end
end

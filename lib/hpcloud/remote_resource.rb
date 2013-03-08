module HP
  module Cloud
    class RemoteResource < Resource
      attr_accessor :directory, :size, :type, :etag, :modified

      DEFAULT_STORAGE_MAX_SIZE = 5368709120
      DEFAULT_STORAGE_SEGMENT_SIZE = 1073741824
      DEFAULT_STORAGE_PAGE_LENGTH = 10000

      @@storage_max_size = nil
      @@storage_segment_size = nil
      @@storage_chunk_size = nil

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
        @lname = @fname
        @sname = @path
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
          return true unless @got_container.nil?
          @got_container = true

          @directory = @storage.directories.get(@container)
          if @directory.nil?
            @cstatus = CliStatus.new("Cannot find container ':#{@container}'.", :not_found)
            return false
          end
          @size = @directory.bytes
          @count = @directory.count
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
          return false if is_valid? == false

          unless @path.empty?
            @file = @directory.files.get(@path)
            if @file.nil?
              @cstatus = CliStatus.new("Cannot find object '#{@fname}'.", :not_found)
              return false
            end
            @size = @file.content_length
            @type = @file.content_type
            @etag = @file.etag
            @modified = @file.last_modified
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
          @directory = @storage.directories.head(@container)
          if @directory.nil?
            @cstatus = CliStatus.new("Cannot find container ':#{@container}'.", :not_found)
            return nil
          end
          @size = @directory.bytes
          @count = @directory.count
          @synckey = @directory.synckey
          @syncto = @directory.syncto
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
        return @directory
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
          return false if container_head().nil?
          return false if get_files == false

          @file_head = @directory.files.head(@path)
          if @file_head.nil?
             @cstatus = CliStatus.new("Cannot find object named '#{@fname}'.", :not_found)
             return false
          end
          @public_url = @file_head.public_url
          @public_url = @public_url.gsub(/%2F/, '/') unless @public_url.nil?
          @public = @directory.public? ? "yes" : "no"
          @readers = @directory.list_users_with_read.join(",")
          @writers = @directory.list_users_with_write.join(",")
        rescue Exception => error
          @cstatus = CliStatus.new("Error reading '#{@fname}': " + error.to_s, :general_error)
          return false
        end
        return true
      end

      def cdn_public_url
          @directory.cdn_public_url
          @cdn_public_url = @file_head.cdn_public_url
          @cdn_public_url = @cdn_public_url.gsub(/%2F/, '/') unless @cdn_public_url.nil?
      end

      def cdn_public_ssl_url
          @cdn_public_ssl_url = @file_head.cdn_public_ssl_url
          @cdn_public_ssl_url = @cdn_public_ssl_url.gsub(/%2F/, '/') unless @cdn_public_ssl_url.nil?
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
        return ! container_head().nil?
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
          if @@storage_segment_size.nil?
            config = Config.new
            @@storage_max_size = config.get_i(:storage_max_size, DEFAULT_STORAGE_MAX_SIZE)
            @@storage_segment_size = config.get_i(:storage_segment_size, DEFAULT_STORAGE_SEGMENT_SIZE)
            @@storage_chunk_size = config.get_i(:storage_chunk_size, Excon::DEFAULT_CHUNK_SIZE)
          end
          @options = { 'Content-Type' => from.get_mime_type() }
          count = 0
          segment = i=10000000001
          total = from.get_size()
          if total >= @@storage_max_size
            prefix = @destination + '.segment.'
            begin
              bytes_read = 0
              bytes_to_read = total - count
              bytes_to_read = @@storage_segment_size if bytes_to_read > @@storage_segment_size
              tmppath = prefix + segment.to_s[1..10]
              already_exists = false
              begin
                if @restart == true
                  response = @storage.head_object(@container, tmppath)
                  segsiz = response.headers['Content-Length'].to_i
                  if segsiz == bytes_to_read
                    already_exists = true
                  end
                end
              rescue
              end
              if already_exists
                while bytes_to_read > 0 do
                  body = from.read(@@storage_chunk_size)
                  bytes_read += body.length
                  bytes_to_read -= body.length
                end
              else
                @storage.put_object(@container, tmppath, nil, @options) {
                  body = from.read(@@storage_chunk_size)
                  bytes_read += body.length
                  bytes_to_read -= body.length
                  body
                }
              end
              count = count + bytes_read
              segment = segment + 1
            end until count >= total
            manifest = @destination
            @options['x-object-manifest'] = @container + '/' + prefix
            @storage.put_object(@container, manifest, nil, @options)
          else
            @storage.put_object(@container, @destination, nil, @options) {
              from.read(@@storage_chunk_size)
            }
          end
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
        case @ftype
        when :container_directory
          regex = "^" + path + ".*"
        when :container
          regex = ".*"
        else
          regex = "^" + path + '$'
        end
        if @@limit.nil?
          @@limit = Config.new.get_i(:storage_page_length, DEFAULT_STORAGE_PAGE_LENGTH)
        end
        total = 0
        count = 0
        marker = nil
        begin
          options = { :limit => @@limit, :marker => marker }
          result = @storage.get_container(@container, options)
          total = result.headers['X-Container-Object-Count'].to_i
          lode = result.body.length
          count += lode
          result.body.each { |x|
            name = x['name']
            unless name.end_with?('/')
              if ! name.match(regex).nil?
                res = ResourceFactory.create(@storage, ':' + @container + '/' + name)
                res.directory = @directory
                res.etag = x['hash']
                res.modified = x['last_modified']
                res.size = x['bytes']
                res.type = x['content_type']
                yield res
                marker = name
              end
            end
          }
          break if lode < @@limit
        end until count >= total
      end

      def get_destination()
        return ':' + @container.to_s + '/' + @destination.to_s
      end

      def remove(force)
        begin
          return false if get_container == false

          file = @directory.files.head(@path)
          if file.nil?
             @cstatus = CliStatus.new("You don't have an object named '#{@fname}'.", :not_found)
             return false
          end
          file.destroy
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
          return nil if get_container == false
          return nil if get_files == false

          return @file.temp_signed_url(period, "GET")
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
        @cstatus = CliStatus.new("ACLs are only supported on containers (e.g. :container).", :not_supported)
        return false
      end

      def revoke(acl)
        @cstatus = CliStatus.new("ACLs are only supported on containers (e.g. :container).", :not_supported)
        return false
      end

      def has_same_account(storage)
        return storage == @storage
      end
    end
  end
end

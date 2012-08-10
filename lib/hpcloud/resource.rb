require 'hpcloud/connection.rb'
require 'progressbar'

module HP
  module Cloud
    class Resource
      attr_reader :fname, :ftype, :container, :path
      attr_reader :destination, :error_string, :error_code
    
      REMOTE_TYPES = [:container, :container_directory, :object]
      LOCAL_TYPES = [:directory, :file]
    
      def self.create(storage, fname)
        if LOCAL_TYPES.include?(detect_type(fname))
          return LocalResource.new(storage, fname)
        end
        return RemoteResource.new(storage, fname)
      end

      def initialize(storage, fname)
        @error_string = nil
        @error_code = nil
        @storage = storage
        @fname = fname
        @ftype = Resource.detect_type(@fname)
        @disable_pbar = false
        parse()
      end

      class << self
        protected :new
      end

      def isLocal()
        return Resource::LOCAL_TYPES.include?(@ftype)
      end

      def isRemote()
        return Resource::REMOTE_TYPES.include?(@ftype)
      end

      def isDirectory()
        return @ftype == :directory ||
               @ftype == :container_directory ||
               @ftype == :container
      end

      def isFile()
        return @ftype == :file
      end

      def isObject()
        return @ftype == :object
      end

      def self.detect_type(resource)
        if resource[0,1] == ':'
          if resource[-1,1] == '/'
            :container_directory
          elsif resource.index('/')
            :object
          else
            :container
          end
        elsif resource[-1,1] == '/'
          :directory
        else
          if File.directory?(resource)
            :directory
          else
            :file
          end
        end
      end
    
      def parse()
        @container = nil
        @path = nil
        if @fname.empty?
          return
        end
        if @fname[0,1] == ':'
          @container, *rest = @fname.split('/')
          @container = @container[1..-1] if @container[0,1] == ':'
          @path = rest.empty? ? '' : rest.join('/')
        else
          rest = @fname.split('/')
          @path = rest.empty? ? '' : rest.join('/')
        end
      end

      def get_mime_type()
        # this probably needs some security lovin'
        full_mime = `file --mime -b #{@fname}`
        full_mime.split(';')[0].chomp
      end

      def valid_source()
        return true
      end

      def valid_destination(source_directory)
        return true
      end

      def set_destination(from)
        return true
      end

      def open(output=false, siz=0)
        return false
      end

      def read()
        return nil
      end

      def write(data)
        return false
      end

      def close()
        return false
      end

      def copy_file(from)
        return false
      end

      def copy(from)
          if copy_all(from)
            return true
          end
          if @error_string.nil?
            if from.error_string.nil?
              @error_string = 'Unknown error copying'
              @error_code = :unknown
            else
              @error_string = from.error_string
              @error_code = from.error_code
            end
          end
          return false
      end

      def copy_all(from)
        if ! from.valid_source() then return false end
        if ! valid_destination(from.isDirectory()) then return false end

        copiedfile = false
        original = File.dirname(from.path)
        from.foreach { |file|
          if (original != '.')
            filename = file.path.sub(original, '').sub(/^\//, '')
          else
            filename = file.path
          end
          if ! set_destination(filename) then return false end
          if (copy_file(file) == false)
            return false
          end
          copiedfile = true
        }

        if (copiedfile == false)
          @error_string = "No files found matching source '#{from.path}'"
          @error_code = :not_found
          return false
        end
        return true
      end

      def foreach(&block)
        return
      end

      def get_destination()
        return @destination.to_s
      end
    end

    class LocalResource < Resource

      def get_size()
        begin
          return File.size(@fname)
        rescue
          return 0
        end
      end

      def valid_source()
        if !File.exists?(@fname)
          @error_string = "File not found at '#{@fname}'."
          @error_code = :not_found
          return false
        end
        return true
      end

      def valid_destination(source_directory)
        if isDirectory()
          dir_path = File.expand_path(@path)
        else
          if source_directory == true
            @error_string = "Invalid target for directory copy '#{@fname}'."
            @error_code = :incorrect_usage
            return false
          end
          dir_path = File.expand_path(File.dirname(@path))
        end
        if !File.directory?(dir_path)
          @error_string = "No directory exists at '#{dir_path}'."
          @error_code = :not_found
          return false
        end
        return true
      end

      def set_destination(name)
        if (@path.nil?)
          @destination = name
        else
          @destination = File.expand_path(@path)
          if isDirectory()
            @destination = "#{@destination}/#{name}"
            dir_path = File.dirname(File.expand_path(@destination))
          else
            dir_path = File.dirname(@destination)
          end
          if !File.directory?(dir_path)
            begin
              FileUtils.mkpath(dir_path)
            rescue Exception => e
              @error_string = "Error creating target directory '#{dir_path}'."
              @error_code = :general_error
              return false
            end
          end
        end
        return true
      end

      def open(output=false, siz=0)
        close()
        @lastread = 0
        begin
          if (output == true)
            @pbar = ProgressBar.new(File.basename(@destination), siz)
            @file = File.open(@destination, 'w')
          else
            if (@disable_pbar == false)
              @pbar = ProgressBar.new(File.basename(@fname), get_size())
            end
            @file = File.open(@fname, 'r')
          end
        rescue Exception => e
          @error_string = e.to_s
          @error_code = :permission_denied
          return false
        end
        return true
      end

      def read()
        @pbar.inc(@lastread) unless @pbar.nil?
        val = @file.read(Excon::CHUNK_SIZE).to_s
        @lastread = val.length
        return val
      end

      def write(data)
        @pbar.inc(data.length) unless @pbar.nil?
        @file.write(data)
        return true
      end

      def close()
        unless @pbar.nil?
          @pbar.inc(@lastread) unless @lastread.nil?
          @pbar.finish
        end
        @lastread = 0
        @pbar = nil
        @file.close unless @file.nil?
        @file = nil
        return true
      end

      def copy_file(from)
        if from.isLocal()
          @disable_pbar = true
        end

        if ! open(true, from.get_size()) then return false end

        result = true
        if from.isLocal()
          if (from.open() == true)
            while ((chunk = from.read()) != nil) do
              if chunk.empty?
                break
              end
              if ! write(chunk.to_s) then result = false end
            end
            result = false if ! from.close()
          else
            result = false
          end
        else
          begin
            @storage.get_object(from.container, from.path) { |chunk, remaining, total|
              if ! write(chunk) then result = false end
            }
          rescue Fog::Storage::HP::NotFound => e
            @error_string = "The specified object does not exist."
            @error_code = :not_found
            result = false
          end
        end
        if ! close() then return false end
        return result
      end

      def foreach(&block)
        if (isDirectory() == false)
           yield self
          return
        end
        begin
          Dir.foreach(path) { |x|
            if ((x != '.') && (x != '..')) then
              Resource.create(@storage, path + '/' + x).foreach(&block)
            end
          }
        rescue Errno::EACCES
          @error_string  = "You don't have permission to access '#{path}'."
          @error_code = :permission_denied
        end
      end
    end

    class RemoteResource < Resource

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

      def valid_source()
        return valid_container()
      end

      def valid_destination(source_directory)
        if ! valid_container()
          return false
        end
        if ((source_directory == true) && (isDirectory() == false))
          @error_string = "Invalid target for directory copy '#{@fname}'."
          @error_code = :incorrect_usage
          return false
        end
        return true
      end

      def valid_container()
        begin
          directory = @storage.directories.get(@container)
          if directory.nil?
            @error_string = "You don't have a container '#{@container}'."
            @error_code = :not_found
            return false
          end
        rescue Excon::Errors::Forbidden => e
          resp = ErrorResponse.new(e)
          # @error_string  = "You don't have permission to access the container '#{@container}'."
          @error_string  = resp.error_string
          @error_code = :permission_denied
          return false
        end
        return true
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
            @destination = @path + '/' + name
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
        directory = @storage.directories.get(@container)
        return if directory.nil?
        case @ftype
        when :container_directory
          regex = "^" + path + ".*"
        when :container
          regex = ".*"
        else
          regex = "^" + path + '$'
        end
        directory.files.each { |x|
          name = x.key.to_s
          if ! name.match(regex).nil?
            yield Resource.create(@storage, ':' + container + '/' + name)
          end
        }
      end

      def get_destination()
        return ':' + @container.to_s + '/' + @destination.to_s
      end
    end
  end
end

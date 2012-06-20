require 'hpcloud/connection.rb'
include HP::Cloud

module HP
  module Cloud
    class Resource
      attr_reader :fname, :ftype, :container, :path
      attr_reader :destination, :error_string, :error_code
    
      REMOTE_TYPES = [:container, :container_directory, :object]
      LOCAL_TYPES = [:directory, :file]
    
      def self.create(fname)
        if LOCAL_TYPES.include?(detect_type(fname))
          return LocalResource.new(fname)
        end
        return RemoteResource.new(fname)
      end

      def initialize(fname)
        @error_string = nil
        @error_code = nil
        @fname = fname
        @ftype = Resource.detect_type(@fname)
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
        return @ftype == :directory
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

      def get_size()
        return File.size(@fname)
      end

      def valid_source()
        return true
      end

      def valid_destination()
        return true
      end

      def set_destination(from)
        return true
      end
    end

    class LocalResource < Resource

      def valid_source()
        if !File.exists?(@fname)
          @error_string = "File not found at '#{@fname}'."
          @error_code = :not_found
          return false
        end
        return true
      end

      def set_destination(from)
        @destination = @path
        if isDirectory()
          @destination = "#{@destination}/#{File.basename(from.path)}"
        end
        dir_path = File.expand_path(File.dirname(@destination))
        if !File.directory?(dir_path)
          dname = File.dirname(@destination)
          @error_string = "No directory exists at '#{dname}'."
          @error_code = :not_found
          return false
        end
        return true
      end
    end

    class RemoteResource < Resource
      def valid_source()
        return valid_container()
      end

      def valid_container()
        begin
          connection = Connection.instance.storage()
          directory = connection.directories.get(@container)
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

      def set_destination(from)
        if ! valid_container()
          return false
        end
        if @path.to_s.empty?
          @destination = File.basename(from.path)
        elsif @fname[-1,1] == '/'
          @destination = @path + '/' + File.basename(from.path)
        else
          @destination = @path
        end
        return true
      end
    end

  end
end

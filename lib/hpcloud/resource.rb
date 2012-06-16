module HP
  module Cloud
    class Resource
      attr_reader :fname, :ftype, :container, :path
    
      REMOTE_TYPES = [:container, :container_directory, :object]
      LOCAL_TYPES = [:directory, :file]
    
      def initialize(fname)
        @fname = fname
        @ftype = Resource.detect_type(@fname)
        parse()
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
    
    end
  end
end

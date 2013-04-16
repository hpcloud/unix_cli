require 'hpcloud/connection.rb'
require 'mime/types'
require 'ruby-progressbar'

module HP
  module Cloud
    class Resource
      attr_accessor :path
      attr_reader :fname, :ftype, :container
      attr_reader :public_url, :readers, :writers, :public
      attr_reader :destination, :cstatus
      attr_reader :restart
    
      @@limit = nil

      def initialize(storage, fname)
        @cstatus = CliStatus.new
        @storage = storage
        @fname = fname
        @ftype = ResourceFactory.detect_type(@fname)
        @disable_pbar = false
        @mime_type = nil
        @restart = false
        @readacl = []
        @writeacl = []
        parse()
      end

      def is_valid?
        return @cstatus.is_success?
      end

      def set_error(from)
        return unless is_valid?
        @cstatus.set(from.cstatus)
      end

      def not_implemented(value)
        @cstatus = CliStatus.new("Not implemented: #{value}")
        return false
      end

      def isLocal()
        return ResourceFactory::is_local?(@ftype)
      end

      def isRemote()
        return ResourceFactory::is_remote?(@ftype)
      end

      def is_object_store?
        return @ftype == :object_store
      end

      def is_container?
        return @ftype == :container
      end

      def is_shared?
        return @ftype == :shared_resource || @ftype == :shared_directory
      end

      def isDirectory()
        return @ftype == :directory ||
               @ftype == :container_directory ||
               @ftype == :shared_directory ||
               @ftype == :container ||
               @ftype == :object_store
      end

      def isFile()
        return @ftype == :file
      end

      def isObject()
        return @ftype == :object || @ftype == :shared_resource
      end

      def parse
        @container = nil
        @path = nil
        if @fname.empty?
          return
        end
        if @fname[0,1] == ':'
          @container, *rest = @fname.split('/')
          @container = @container[1..-1] if @container[0,1] == ':'
          @path = rest.empty? ? '' : rest.join('/')
          unless @container.length < 257
            raise Exception.new("Valid container names must be less than 256 characters long")
          end
        else
          rest = @fname.split('/')
          @path = rest.empty? ? '' : rest.join('/')
        end
      end

      def to_hash
        hash = {}
        instance_variables.each {|var| hash[var.to_s.delete("@")] = instance_variable_get(var) }
        hash
      end

      def set_mime_type(value)
        @mime_type = value.tr("'", "") unless value.nil?
      end

      def get_mime_type()
        return @mime_type unless @mime_type.nil?
        filename = ::File.basename(@fname)
        unless (mime_types = ::MIME::Types.of(filename)).empty?
          return mime_types.first.content_type
        end
        return 'application/octet-stream'
      end

      def valid_source()
        return true
      end

      def isMulti()
        return true if isDirectory()
        found = false 
        foreach { |x|
          if (found == true)
            return true
          end
          found = true
        }
        return false
      end

      def valid_destination(source)
        return true
      end

      def set_destination(from)
        return true
      end

      def head()
        @cstatus = CliStatus.new("Not supported on local object '#{@fname}'.", :not_supported)
        return false
      end

      def container_head()
        @cstatus = CliStatus.new("Not supported on local object '#{@fname}'.", :not_supported)
        return false
      end

      def open(output=false, siz=0)
        return not_implemented("open")
      end

      def read()
        not_implemented("read")
        return nil
      end

      def write(data)
        return not_implemented("write")
      end

      def close()
        return not_implemented("close")
      end

      def copy_file(from)
        return not_implemented("copy_file")
      end

      def copy(from)
          if copy_all(from)
            return true
          end
          set_error(from)
          return false
      end

      def copy_all(from)
        if ! from.valid_source()
          @cstatus = from.cstatus
          return false
        end
        if ! valid_destination(from) then return false end

        copiedfile = false
        original = File.dirname(from.path)
        from.foreach { |file|
          if (original != '.')
            filename = file.path.sub(original, '').sub(/^\//, '')
          else
            filename = file.path
          end
          return false unless set_destination(filename)
          unless copy_file(file)
            from.set_error(file)
            return false
          end
          copiedfile = true
        }

        if (copiedfile == false)
          @cstatus = CliStatus.new("No files found matching source '#{from.path}'", :not_found)
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

      def remove(force, at=nil, after=nil)
        @cstatus = CliStatus.new("Removal of local objects is not supported: #{@fname}", :incorrect_usage)
        return false
      end

      def tempurl(period = 172800)
        @cstatus = CliStatus.new("Temporary URLs of local objects is not supported: #{@fname}", :incorrect_usage)
        return nil
      end

      def grant(acl)
        @cstatus = CliStatus.new("ACLs of local objects are not supported: #{@fname}", :incorrect_usage)
        return false
      end

      def revoke(acl)
        @cstatus = CliStatus.new("ACLs of local objects are not supported: #{@fname}", :incorrect_usage)
        return false
      end

      def set_restart(value)
        @restart = value
      end
    end
  end
end

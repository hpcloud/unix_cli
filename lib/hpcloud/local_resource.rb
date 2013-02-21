module HP
  module Cloud
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
          @cstatus = CliStatus.new("File not found at '#{@fname}'.", :not_found)
          return false
        end
        return true
      end

      def valid_destination(source)
        if isDirectory()
          dir_path = File.expand_path(@path)
        else
          if source.isMulti() == true
            @cstatus = CliStatus.new("Invalid target for directory/multi-file copy '#{@fname}'.", :incorrect_usage)
            return false
          end
          dir_path = File.expand_path(File.dirname(@path))
        end
        if !File.directory?(dir_path)
          @cstatus = CliStatus.new("No directory exists at '#{dir_path}'.", :not_found)
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
              @cstatus = CliStatus.new("Error creating target directory '#{dir_path}'.", :general_error)
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
            @pbar = Progress.new(@destination, siz)
            @file = File.open(@destination, 'w')
          else
            if (@disable_pbar == false)
              @pbar = Progress.new(@fname, get_size())
            end
            @file = File.open(@fname, 'r')
          end
        rescue Exception => e
          @cstatus = CliStatus.new(e.to_s, :permission_denied)
          return false
        end
        return true
      end

      def read(siz = Excon::CHUNK_SIZE)
        @pbar.increment(@lastread) unless @pbar.nil?
        if siz == 0
          @lastread = 0
          return ''
        end
        val = @file.read(siz).to_s
        @lastread = val.length
        return val
      end

      def write(data)
        @pbar.increment(data.length) unless @pbar.nil?
        @file.write(data)
        return true
      end

      def close()
        @pbar.increment(@lastread) unless @pbar.nil?
        @pbar.finish unless @pbar.nil?
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

        return false unless open(true, from.get_size())

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
          from.read() { |chunk|
            if ! write(chunk) 
              result = false
              break
            end
          }
          result = false unless from.close()
          unless from.is_valid?
            set_error(from)
            result = false
          end
        end
        return false unless close()
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
              ResourceFactory.create_any(@storage, path + '/' + x).foreach(&block)
            end
          }
        rescue Errno::EACCES
          @cstatus  = CliStatus.new("You don't have permission to access '#{path}'.", :permission_denied)
        end
      end
    end
  end
end

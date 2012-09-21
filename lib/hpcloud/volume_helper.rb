module HP
  module Cloud
    class VolumeHelper
      @@serverous = nil
      attr_accessor :error_string, :error_code, :fog, :snapshot_id
      attr_accessor :id, :name, :size, :type, :created, :status, :description, :servers
      attr_accessor :meta
    
      def self.get_keys()
        return [ "id", "name", "size", "type", "created", "status", "description", "servers" ]
      end

      def initialize(connection, volume = nil)
        @connection = connection
        @error_string = nil
        @error_code = nil
        @fog = volume
        if volume.nil?
          @meta = HP::Cloud::Metadata.new(nil)
          return
        end
        @id = volume.id
        @name = volume.name
        @size = volume.size
        @type = volume.type
        @created = volume.created_at
        @status = volume.status
        @description = volume.description
        @servers = ''
        @@serverous = Servers.new if @@serverous.nil?
        volume.attachments.each { |x|
          srv = @@serverous.get(x["serverId"].to_s)
          if srv.is_valid? == false
            next
          end
          if @servers.length > 0
            @servers += ','
          end
          @servers += srv.name
        }
# Meta issues need to be resolved
#        @meta = HP::Cloud::Metadata.new(volume.metadata)
      end

      def to_hash
        hash = {}
        instance_variables.each {|var| hash[var.to_s.delete("@")] = instance_variable_get(var) }
        hash
      end

      def save
        if is_valid?
          @error_string = @meta.error_string
          @error_code = @meta.error_code
        end
        return false if is_valid? == false
        if @fog.nil?
          hsh = {:name => @name,
             :description => @description,
             :size => @size,
             :metadata => @meta.hsh}
          hsh[:snapshot_id] = @snapshot_id unless @snapshot_id.nil?
          volume = @connection.block.volumes.create(hsh)
          if volume.nil?
            @error_string = "Error creating volume '#{@name}'"
            @error_code = :general_error
            return false
          end
          @id = volume.id
          @fog = volume
          return true
        else
          raise "Update not implemented"
        end
      end

      def attach(server, device)
        begin
          @fog.attach(server.id, device)
        rescue Exception => e
          @error_string = "Error attaching '#{name}' on server '#{server.name}' to device '#{device}'."
          @error_code = :general_error
          return false
        end
        return true
      end

      def detach()
        begin
          @fog.detach
        rescue Exception => e
          @error_string = "Error detaching '#{name}' from '#{@servers}'."
          @error_code = :general_error
          return false
        end
        return true
      end

      def is_valid?
        return @error_string.nil?
      end

      def destroy
        @fog.destroy unless @fog.nil?
      end

      def self.clear_cache
        @@serverous = nil
      end
    end
  end
end

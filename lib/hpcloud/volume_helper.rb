module HP
  module Cloud
    class VolumeHelper < BaseHelper
      @@serverous = nil
      attr_accessor :id, :name, :size, :type, :created, :status, :description, :servers, :snapshot_id, :imageref
      attr_accessor :meta
    
      def self.get_keys()
        return [ "id", "name", "size", "type", "created", "status", "description", "servers" ]
      end

      def initialize(connection, foggy = nil)
        super(connection, foggy)
        if foggy.nil?
          @meta = HP::Cloud::Metadata.new(nil)
          return
        end
        @id = foggy.id
        @name = foggy.name
        @size = foggy.size
        @type = foggy.type
        @created = foggy.created_at
        @status = foggy.status
        @description = foggy.description
        @servers = ''
        @@serverous = Servers.new if @@serverous.nil?
        foggy.attachments.each { |x|
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
#        @meta = HP::Cloud::Metadata.new(foggy.metadata)
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
          hsh[:image_id] = @imageref unless @imageref.nil?
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

      def self.clear_cache
        @@serverous = nil
      end

      def map_device(device)
        begin
          return "/dev/sda" if device == "0"
          i = device.to_i
          return device if i < 1 || i > 25
          i = i +  97
          return "/dev/sd" + i.chr
        rescue Exception => e
        end
        return device
      end
    end
  end
end

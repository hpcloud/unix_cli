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
      end

      def save
        return false if is_valid? == false
        if @fog.nil?
          hsh = {:name => @name,
             :description => @description,
             :size => @size}
          hsh[:snapshot_id] = @snapshot_id unless @snapshot_id.nil?
          hsh[:image_id] = @imageref unless @imageref.nil?
          volume = @connection.block.volumes.create(hsh)
          if volume.nil?
            set_error("Error creating volume '#{@name}'")
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
          set_error("Error attaching '#{name}' on server '#{server.name}' to device '#{device}'.")
          return false
        end
        return true
      end

      def detach()
        begin
          @fog.detach
        rescue Exception => e
          set_error("Error detaching '#{name}' from '#{@servers}'.")
          return false
        end
        return true
      end

      def self.clear_cache
        @@serverous = nil
      end

      def map_device(device)
        begin
          return "/dev/vda" if device == "0"
          i = device.to_i
          return device if i < 1 || i > 26
          i = i +  96
          return "/dev/vd" + i.chr
        rescue Exception => e
        end
        return device
      end
    end
  end
end

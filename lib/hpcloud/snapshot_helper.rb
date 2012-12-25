module HP
  module Cloud
    class SnapshotHelper < BaseHelper
      @@volumous = nil
      attr_accessor :id, :name, :volume, :size, :created, :status, :description
    
      def self.get_keys()
        return [ "id", "name", "volume", "size", "created", "status", "description" ]
      end

      def initialize(connection, foggy = nil)
        super(connection, foggy)
        return if foggy.nil?
        @id = foggy.id
        @name = foggy.name
        set_volume(foggy.volume_id)
        @size = foggy.size
        @created = foggy.created_at
        @status = foggy.status
        @description = foggy.description
      end

      def set_volume(volume_name_id)
        @@volumous = Volumes.new if @@volumous.nil?
        @volume_obj = @@volumous.get(volume_name_id.to_s)
        if @volume_obj.is_valid? == false
          return false
        end
        @volume = @volume_obj.name
        return true
      end

      def save
        return false if is_valid? == false
        if @fog.nil?
          hsh = {:name => @name,
             :volume_id => @volume_obj.id,
             :description => @description}
          snapshot = @connection.block.snapshots.create(hsh)
          if snapshot.nil?
            set_error("Error creating snapshot '#{@name}'")
            return false
          end
          @id = snapshot.id
          @fog = snapshot
          return true
        else
          raise "Update not implemented"
        end
      end

      def self.clear_cache
        @@volumous = nil
      end
    end
  end
end

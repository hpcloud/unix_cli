module HP
  module Cloud
    class SnapshotHelper
      @@volumous = nil
      attr_accessor :error_string, :error_code, :fog
      attr_accessor :id, :name, :volume, :size, :created, :status, :description
    
      def self.get_keys()
        return [ "id", "name", "volume", "size", "created", "status", "description" ]
      end

      def initialize(connection, snapshot = nil)
        @connection = connection
        @error_string = nil
        @error_code = nil
        @fog = snapshot
        return if snapshot.nil?
        @id = snapshot.id
        @name = snapshot.name
        set_volume(snapshot.volume_id)
        @size = snapshot.size
        @created = snapshot.created_at
        @status = snapshot.status
        @description = snapshot.description
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

      def to_hash
        hash = {}
        instance_variables.each {|var| hash[var.to_s.delete("@")] = instance_variable_get(var) }
        hash
      end

      def save
        return false if is_valid? == false
        if @fog.nil?
          hsh = {:name => @name,
             :volume_id => @volume_obj.id,
             :description => @description}
          snapshot = @connection.block.snapshots.create(hsh)
          if snapshot.nil?
            @error_string = "Error creating snapshot '#{@name}'"
            @error_code = :general_error
            return false
          end
          @id = snapshot.id
          @fog = snapshot
          return true
        else
          raise "Update not implemented"
        end
      end

      def is_valid?
        return @error_string.nil?
      end

      def destroy
        @fog.destroy unless @fog.nil?
      end

      def self.clear_cache
        @@volumous = nil
      end
    end
  end
end

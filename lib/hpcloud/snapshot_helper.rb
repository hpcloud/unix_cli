module HP
  module Cloud
    class SnapshotHelper
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
        @volume = snapshot.volume
        @size = snapshot.size
        @created = snapshot.created_at
        @status = snapshot.status
        @description = snapshot.description
        list = Servers.new
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
             :description => @description,
             :size => @size }
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
    end
  end
end

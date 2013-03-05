module HP
  module Cloud
    class LbaasHelper < BaseHelper
      attr_accessor :id, :name, :size, :type, :status
      attr_accessor :meta
    
      def self.get_keys()
        return [ "id", "name", "size", "type", "status" ]
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
        @status = foggy.status
        @meta = HP::Cloud::Metadata.new(foggy.metadata)
      end

      def save
        if is_valid?
          set_error(@meta.cstatus)
        end
        return false if is_valid? == false
        if @fog.nil?
          hsh = {:name => @name,
             :description => @description,
             :size => @size,
             :metadata => @meta.hsh}
          lbaas = @connection.lbaas.create(hsh)
          if lbaas.nil?
            set_error("Error creating lbaas '#{@name}'")
            return false
          end
          @id = lbaas.id
          @fog = lbaas
          return true
        else
          raise "Update not implemented"
        end
      end
    end
  end
end

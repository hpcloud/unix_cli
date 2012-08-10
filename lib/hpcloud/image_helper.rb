require 'hpcloud/metadata'

module HP
  module Cloud
    class ImageHelper
      attr_reader :error_string, :error_code, :meta, :fog
      attr_accessor :id, :name, :created_at, :status
    
      def self.get_keys()
        return ["id", "name", "created_at", "status"]
      end 
        
      def initialize(s = nil)
        @error_string = nil
        @error_code = nil
        @fog = s
        if s.nil?
          @meta = HP::Cloud::Metadata.new(nil)
          return
        end
        @id = s.id
        @name = s.name
        @created_at = s.created_at
        @status = s.status
        @meta = HP::Cloud::Metadata.new(s.metadata)
      end

      def set_server(value)
        @server_name_id = value
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
          server = Servers.new.get(@server_name_id)
          if server.is_valid? == false
            @error_string = server.error_string
            @error_code = server.error_code
            return false
          end

          @id = server.create_image(@name , @meta.hsh)
          if @id.nil?
            @error_string = server.error_string
            @error_code = server.error_code
            return false
          end
          return true
        end
        raise "Update not implemented"
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

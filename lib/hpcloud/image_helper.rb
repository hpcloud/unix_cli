require 'hpcloud/metadata'

module HP
  module Cloud
    class ImageHelper
      OS_TYPES = { :ubuntu => 0,
                   :centos => 1,
                   :fedora => 2,
                   :debian => 3,
                   :windows => 4
                 }
      attr_reader :meta, :fog
      attr_accessor :error_string, :error_code
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

      def is_windows?
        return (@meta.hsh['hp_image_license'].nil? == false)
      end

      def is_valid?
        return @error_string.nil?
      end

      def destroy
        @fog.destroy unless @fog.nil?
      end

      def os
        return :windows if is_windows?
        return :ubuntu if name.nil?
        return :windows unless name.match(/[wW][iI][nN][dD][oO][wW]/).nil?
        return :fedora unless name.match(/[fF][eE][dD][oO][rR][aA]/).nil?
        return :centos unless name.match(/[cC][eE][nN][tT][oO][sS]/).nil?
        return :debian unless name.match(/[dD][eE][bB][iI][aA][nN]/).nil?
        return :ubuntu
      end

      def login
        case os
        when :ubuntu 
          return 'ubuntu'
        when :centos, :fedora, :debian
          return 'root'
        when :windows
          return 'Administrator'
        end
        return 'ubuntu'
      end
    end
  end
end

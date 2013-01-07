require 'hpcloud/metadata'

module HP
  module Cloud
    class ImageHelper < BaseHelper
      OS_TYPES = { :ubuntu => 0,
                   :centos => 1,
                   :fedora => 2,
                   :debian => 3,
                   :windows => 4
                 }
      attr_reader :meta
      attr_accessor :id, :name, :created_at, :status
    
      def self.get_keys()
        return ["id", "name", "created_at", "status"]
      end 
        
      def initialize(foggy = nil)
        super(nil, foggy)
        if foggy.nil?
          @meta = HP::Cloud::Metadata.new(nil)
          return
        end
        @id = foggy.id
        @name = foggy.name
        @created_at = foggy.created_at
        @status = foggy.status
        @meta = HP::Cloud::Metadata.new(foggy.metadata)
      end

      def set_server(value)
        @server_name_id = value
      end

      def save
        if is_valid?
          set_error(@meta.cstatus)
        end
        return false if is_valid? == false
        if @fog.nil?
          server = Servers.new.get(@server_name_id)
          if server.is_valid? == false
            set_error(server.cstatus)
            return false
          end

          @id = server.create_image(@name , @meta.hsh)
          if @id.nil?
            set_error(server.cstatus)
            return false
          end
          return true
        end
        raise "Update not implemented"
      end

      def is_windows?
        return (@meta.hsh['hp_image_license'].nil? == false)
      end

      def is_private?
        return false if @meta.hsh['owner'].nil?
        return @meta.hsh['owner'].empty? == false
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

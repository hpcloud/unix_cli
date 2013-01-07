module HP
  module Cloud
    class VolumeAttachment
      attr_accessor :cstatus
      attr_accessor :id, :device, :serverId, :volumeId, :name, :server
      attr_accessor :meta
    
      def self.get_keys()
        return [ "id", "name", "server", "device" ]
      end

      def initialize(va = nil)
        @cstatus = CliStatus.new
        @fog_va = va
        if va.nil?
          return
        end
        @id = va["id"]
        @device = va["device"]
        @serverId = va["serverId"]
        @volumeId = va["volumeId"]
        @name = va["name"]
        @server = va["server"]
      end

      def to_hash
        hash = {}
        instance_variables.each {|var| hash[var.to_s.delete("@")] = instance_variable_get(var) }
        hash
      end

      def is_valid?
        return @cstatus.is_success?
      end
    end
  end
end

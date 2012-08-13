require 'hpcloud/fog_collection'
require 'hpcloud/volume_helper'

module HP
  module Cloud
    class VolumeAttachments < FogCollection
      def initialize(server)
        super("volume_attachment")
        @items = []
        volumes = Volumes.new
        begin
          rsp = @connection.compute.list_server_volumes(server.id.to_s)
        rescue Exception => e
          raise Exception.new("List server volumes call failed")
        end

        if rsp.nil? || rsp.body.nil? || rsp.body["volumeAttachments"].nil?
          raise Exception.new("List server volumes should include response body with volumeAttachments")
        end

        rsp.body["volumeAttachments"].each { |hsh|
          hsh["server"] = server.name
          vol = volumes.get(hsh["volumeId"].to_s)
          if vol.is_valid?
            hsh["name"] = vol.name
          end
          @items << hsh
        }
        return
      end

      def create(item = nil)
        return VolumeAttachment.new(item)
      end
    end
  end
end

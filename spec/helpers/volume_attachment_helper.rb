
class VolumeAttachmentHelper
  def self.createHash(id)
    fog_hash = {}
    fog_hash["device"] = "/dev/sd" + id
    fog_hash["serverId"] = "1" + id
    fog_hash["id"] = id
    fog_hash["volumeId"] = "2" + id
    fog_hash["name"] = "vol2" + id
    fog_hash["server"] = "srv1" + id
    return fog_hash
  end
end

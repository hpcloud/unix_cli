
class VolumeTestHelper
  @@volume_cache = {}

  def self.create(name)
    return @@volume_cache[name] unless @@volume_cache[name].nil?
    volumes = HP::Cloud::Volumes.new
    volume = volumes.get(name)
    if volume.is_valid?
      if volume.meta.nil?
        volume.meta = HP::Cloud::Metadata.new(nil)
      end
      @@volume_cache[name] = volume
      return volume
    end
    volume = volumes.create()
    volume.name = name
    volume.size = 1
    volume.save
    volume.fog.wait_for { ready? }
    @@volume_cache[name] = volume
    return volume
  end
end

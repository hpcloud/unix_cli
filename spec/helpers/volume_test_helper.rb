
class VolumeTestHelper
  def self.create(name)
    volumes = HP::Cloud::Volumes.new
    volume = volumes.get(name)
    if volume.is_valid?
      if volume.meta.nil?
        volume.meta = HP::Cloud::Metadata.new(nil)
      end
      return volume
    end
    volume = volumes.create()
    volume.name = name
    volume.size = 1
    volume.save
    volume.fog.wait_for { ready? }
    return volume
  end
end

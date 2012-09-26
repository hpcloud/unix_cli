
class SnapshotTestHelper
  @@snapshot_cache = {}

  def self.create(name, volume)
    return @@snapshot_cache[name] unless @@snapshot_cache[name].nil?
    snapshots = HP::Cloud::Snapshots.new
    snapshot = snapshots.get(name)
    if snapshot.is_valid?
      @@snapshot_cache[name] = snapshot
      return snapshot
    end
    snapshot = snapshots.create()
    snapshot.name = name
    snapshot.set_volume(volume.id)
    snapshot.description = "CLI Test"
    snapshot.save
    snapshot.fog.wait_for { ready? }
    @@snapshot_cache[name] = snapshot
    return snapshot
  end
end

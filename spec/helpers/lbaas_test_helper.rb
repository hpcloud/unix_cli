
class LbaasTestHelper
  @@lbaas_cache = {}

  def self.create(name)
    return @@lbaas_cache[name] unless @@lbaas_cache[name].nil?
    lbaass = HP::Cloud::Lbaass.new
    lbaas = lbaass.get(name)
    if lbaas.is_valid?
      if lbaas.meta.nil?
        lbaas.meta = HP::Cloud::Metadata.new(nil)
      end
      @@lbaas_cache[name] = lbaas
      return lbaas
    end
    lbaas = lbaass.create()
    lbaas.name = name
    lbaas.size = 1
    lbaas.save
    lbaas.fog.wait_for { ready? }
    @@lbaas_cache[name] = lbaas
    return lbaas
  end
end


class LbTestHelper
  @@lb_cache = {}

  def self.create(name)
    return @@lb_cache[name] unless @@lb_cache[name].nil?
    lbs = HP::Cloud::Lbs.new
    lb = lbs.get(name)
    if lb.is_valid?
      if lb.meta.nil?
        lb.meta = HP::Cloud::Metadata.new(nil)
      end
      @@lb_cache[name] = lb
      return lb
    end
    lb = lbs.create()
    lb.name = name
    lb.size = 1
    lb.save
    lb.fog.wait_for { ready? }
    @@lb_cache[name] = lb
    return lb
  end
end

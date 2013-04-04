
class RouterTestHelper
  @@router_cache = {}

  def self.create(name)
    return @@router_cache[name] unless @@router_cache[name].nil?
    routers = HP::Cloud::Routers.new
    router = routers.get(name)
    if router.is_valid?
      @@router_cache[name] = router
      return router
    end
    network1 = NetworkTestHelper.create("Ext-Net")
    router = HP::Cloud::RouterHelper.new(Connection.instance)
    router.name = name
    router.set_gateway(network1.id)
    router.save
    @@router_cache[name] = router
    return router
  end
end

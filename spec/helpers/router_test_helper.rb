
class RouterTestHelper
  def self.create(name)
    routers = HP::Cloud::Routers.new
    router = routers.get(name)
    if router.is_valid?
      return router
    end
    network1 = NetworkTestHelper.create("Ext-Net")
    router = HP::Cloud::RouterHelper.new(Connection.instance)
    router.name = name
    router.set_gateway(network1.id)
    router.save
    return router
  end
end

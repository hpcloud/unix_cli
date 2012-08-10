
class ServerTestHelper
  def self.create(name)
    servers = HP::Cloud::Servers.new
    server = servers.get(name)
    if server.is_valid?
      return server
    end
    server = servers.create()
    server.name = name
    server.flavor = OS_COMPUTE_BASE_FLAVOR_ID
    server.image = OS_COMPUTE_BASE_IMAGE_ID
    server.save
    server.fog.wait_for { ready? }
    return server
  end
end

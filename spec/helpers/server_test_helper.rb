
class ServerTestHelper
  def self.create(name)
    servers = HP::Cloud::Servers.new
    server = servers.get(name)
    if server.is_valid?
      return server
    end
    server = servers.create()
    server.name = name
    server.flavor = AccountsHelper.get_flavor_id()
    server.image = AccountsHelper.get_image_id()
    server.save
    server.fog.wait_for { ready? }
    return server
  end
end

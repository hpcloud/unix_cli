
class ServerTestHelper
  @@server_cache = {}

  def self.create(name)
    return @@server_cache[name] unless @@server_cache[name].nil?
    keypair = KeypairTestHelper.create("cli_test_key1")
    servers = HP::Cloud::Servers.new
    server = servers.get(name)
    if server.is_valid?
      @@server_cache[name] = server
      return server
    end
    server = servers.create()
    server.name = name
    server.flavor = AccountsHelper.get_flavor_id()
    server.image = AccountsHelper.get_image_id()
    server.set_keypair(keypair.name)
    server.save
    server.fog.wait_for { ready? }
    @@server_cache[name] = server
    return server
  end
end

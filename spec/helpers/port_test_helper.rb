
class PortTestHelper
  @@port_cache = {}

  def self.create(name)
    return @@port_cache[name] unless @@port_cache[name].nil?
    ports = HP::Cloud::Ports.new
    port = ports.get(name)
    if port.is_valid?
      @@port_cache[name] = port
      return port
    end
    network1 = NetworkTestHelper.create("cli_test_network1")
    port = HP::Cloud::PortHelper.new(Connection.instance)
    port.name = name
    port.network_id = network1.id
    port.save
    @@port_cache[name] = port
    return port
  end
end


class PortTestHelper
  def self.create(name)
    ports = HP::Cloud::Ports.new
    port = ports.get(name)
    if port.is_valid?
      return port
    end
    network1 = NetworkTestHelper.create("cli_test_network1")
    port = HP::Cloud::PortHelper.new(Connection.instance)
    port.name = name
    port.network_id = network1.id
    port.save
    return port
  end
end

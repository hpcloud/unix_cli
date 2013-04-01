
class NetworkTestHelper
  @@network_cache = {}

  def self.create(name)
    return @@network_cache[name] unless @@network_cache[name].nil?
    networks = HP::Cloud::Networks.new
    network = networks.get(name)
    if network.is_valid?
      @@network_cache[name] = network
      return network
    end
    network = HP::Cloud::NetworkHelper.new(Connection.instance)
    network.name = name
    network.save
    @@network_cache[name] = network
    return network
  end
end

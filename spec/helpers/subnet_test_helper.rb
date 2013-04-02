
class SubnetTestHelper
  @@subnet_cache = {}

  def self.create(name)
    return @@subnet_cache[name] unless @@subnet_cache[name].nil?
    subnets = HP::Cloud::Subnets.new
    subnet = subnets.get(name)
    if subnet.is_valid?
      @@subnet_cache[name] = subnet
      return subnet
    end
    network1 = NetworkTestHelper.create("cli_test_network1")
    subnet = HP::Cloud::SubnetHelper.new(Connection.instance)
    subnet.name = name
    subnet.network_id = network1.id
    subnet.set_cidr("127.0.0.0/24")
    subnet.set_gateway_ip("127.0.0.1")
    subnet.enable_dhcp = true
    subnet.save
    @@subnet_cache[name] = subnet
    return subnet
  end
end

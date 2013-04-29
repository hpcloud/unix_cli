
class DnsTestHelper
  @@dns_cache = {}

  def self.create(name)
    return @@dns_cache[name] unless @@dns_cache[name].nil?
    dnss = HP::Cloud::Dnss.new
    dns = dnss.get(name)
    if dns.is_valid?
      @@dns_cache[name] = dns
      return dns
    end
    dns = dnss.create()
    dns.name = name
    dns.ttl = 7200
    dns.email = "clitest@example.com"
    dns.save
    @@dns_cache[name] = dns
    return dns
  end
end


class DnsTestHelper
  @@dns_cache = {}

  def self.create(name)
    return @@dns_cache[name] unless @@dns_cache[name].nil?
    dnss = HP::Cloud::Dnss.new
    dns = dnss.get(name)
    if dns.is_valid?
      if dns.meta.nil?
        dns.meta = HP::Cloud::Metadata.new(nil)
      end
      @@dns_cache[name] = dns
      return dns
    end
    dns = dnss.create()
    dns.name = name
    dns.size = 1
    dns.save
    dns.fog.wait_for { ready? }
    @@dns_cache[name] = dns
    return dns
  end
end

class RuleTestHelper
  @@id = 1

  def self.mock(name)
    fog_rule = { 'id' => @@id,
                 'remote_group_id' => name,
                 'direction' => 'egress',
                 'remote_ip_prefix' => nil,
                 'protocol' => 'icmp',
                 'ethertype' => 'IPv4',
                 'tenant_id' => '2134234234',
                 'port_range_max' => 3333,
                 'port_range_min' => 2222,
                 'security_group_id' => '20202020202'
               }
    @@id += 1
    return fog_rule 
  end
end

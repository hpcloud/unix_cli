
class SecurityGroupTestHelper
  @@securitygroup_cache = {}

  def self.create(name)
    return @@securitygroup_cache[name] unless @@securitygroup_cache[name].nil?
    securitygroups = HP::Cloud::SecurityGroups.new
    securitygroup = securitygroups.get(name)
    if securitygroup.is_valid?
      @@securitygroup_cache[name] = securitygroup
      return securitygroup
    end
    securitygroup = securitygroups.create()
    securitygroup.name = name
    securitygroup.description = "Description: #{name}"
    securitygroup.save
    @@securitygroup_cache[name] = securitygroup
    return securitygroup
  end
end

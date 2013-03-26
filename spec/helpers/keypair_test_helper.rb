
class KeypairTestHelper
  @@keypair_cache = {}

  def self.create(name)
    return @@keypair_cache[name] unless @@keypair_cache[name].nil?
    keypairs = HP::Cloud::Keypairs.new
    keypair = keypairs.get(name)
    if keypair.is_valid?
      @@keypair_cache[name] = keypair
      return keypair
    end
    keypair = keypairs.create()
    keypair.name = name
    keypair.save
    keypair.private_add
    @@keypair_cache[name] = keypair
    return keypair
  end
end

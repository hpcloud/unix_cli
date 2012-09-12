RSpec.configure do |config|

  ### This helper is required because keypair.get(name) does not work
  def get_keypair(connection, key_name)
    connection ||= compute_connection
    connection.key_pairs.get(key_name)
  end

  def del_keypair(connection, key_name)
    kp = get_keypair(connection, key_name)
    kp.destroy unless kp.nil?
  end
end

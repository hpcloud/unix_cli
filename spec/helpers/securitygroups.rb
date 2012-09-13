RSpec.configure do |config|

  ### This helper is required because keypair.get(name) does not work
  def get_securitygroup(connection, sg_name)
    connection ||= compute_connection
    connection.security_groups.select {|sg| sg.name == sg_name}.first
  end
  def del_securitygroup(connection, sg_name)
    sg = get_securitygroup(connection, sg_name)
    sg.destroy unless sg.nil?
  end
end

RSpec.configure do |config|

  ### This helper is required because addresses.get(ip) does not work
  def get_address(connection = nil, public_ip)
    connection ||= compute_connection
    connection.addresses.select {|a| a.ip == public_ip}.first
  end
end


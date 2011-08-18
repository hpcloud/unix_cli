RSpec.configure do |config|

  ### This helper is required because servers.get(id) does not work
  def get_server(connection = nil, id)
    connection ||= compute_connection
    connection.servers.select {|s| s.id == id}.first
  end
end
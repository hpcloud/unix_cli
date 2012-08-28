
require 'hpcloud/connection'

RSpec.configure do |config|
  def storage_connection
    HP::Cloud::Connection.instance.storage()
  end
  
  def compute_connection()
    HP::Cloud::Connection.instance.compute()
  end

  def cdn_connection()
    HP::Cloud::Connection.instance.cdn()
  end
end

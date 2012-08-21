
require 'hpcloud/connection'

RSpec.configure do |config|
  def storage_connection(user = :primary)
    if user == :secondary
      account = 'secondary'
    else
      account = 'primary'
    end
    HP::Cloud::Connection.instance.storage(account)
  end
  
  def compute_connection()
    HP::Cloud::Connection.instance.compute('primary')
  end

  def cdn_connection()
    HP::Cloud::Connection.instance.cdn('primary')
  end
end

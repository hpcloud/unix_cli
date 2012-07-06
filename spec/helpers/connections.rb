

RSpec.configure do |config|
  
  def storage_connection(user = :primary, options = {})
    Connection.instance.set_options(options)
    if user == :secondary
      Connection.instance.storage('secondary')
    else
      Connection.instance.storage('primary')
    end
  end
  
  def compute_connection(options = {})
    Connection.instance.set_options(options)
    Connection.instance.compute('compute')
  end

  def cdn_connection(options = {})
    Connection.instance.set_options(options)
    Connection.instance.cdn('primary')
  end

end

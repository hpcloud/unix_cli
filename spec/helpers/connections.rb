

RSpec.configure do |config|
  
  def storage_connection(user = :primary, options = {})
    Connection.instance.set_options(options)
    if user == :secondary
      account = 'secondary'
      HP::Cloud::Config.set_credentials(account, OS_STORAGE_SEC_ACCOUNT_USERNAME, OS_STORAGE_SEC_ACCOUNT_PASSWORD, OS_STORAGE_AUTH_URL, OS_STORAGE_SEC_ACCOUNT_TENANT_ID)
    else
      account = 'default'
      HP::Cloud::Config.set_credentials(account, OS_STORAGE_ACCOUNT_USERNAME, OS_STORAGE_ACCOUNT_PASSWORD, OS_STORAGE_AUTH_URL, OS_STORAGE_ACCOUNT_TENANT_ID)
    end
    Connection.instance.storage(account)
  end
  
  def compute_connection(options = {})
    Connection.instance.set_options(options)
    HP::Cloud::Config.set_credentials('default', OS_COMPUTE_ACCOUNT_USERNAME, OS_COMPUTE_ACCOUNT_PASSWORD, OS_COMPUTE_AUTH_URL, OS_COMPUTE_ACCOUNT_TENANT_ID)
    Connection.instance.compute
  end

  def cdn_connection(options = {})
    Connection.instance.set_options(options)
    HP::Cloud::Config.set_credentials('default', OS_STORAGE_ACCOUNT_USERNAME, OS_STORAGE_ACCOUNT_PASSWORD, OS_STORAGE_AUTH_URL, OS_STORAGE_ACCOUNT_TENANT_ID)
    Connection.instance.cdn
  end

end

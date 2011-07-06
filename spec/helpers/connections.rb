

RSpec.configure do |config|
  
  # Create a new Storage service connection - maybe memoize later
  def storage_connection(user = :primary)
    if user == :primary
      Fog::Storage.new( :provider     => 'HP',
                        :hp_host      => OS_STORAGE_HOST,
                        :hp_port      => OS_STORAGE_PORT,
                        :hp_auth_path => OS_STORAGE_AUTH_PATH,
                        :hp_password  => OS_STORAGE_ACCOUNT_PASSWORD,
                        :hp_username  => OS_STORAGE_ACCOUNT_USERNAME )
    elsif user == :secondary
      Fog::Storage.new( :provider     => 'HP',
                        :hp_host      => OS_STORAGE_HOST,
                        :hp_port      => OS_STORAGE_PORT,
                        :hp_auth_path => OS_STORAGE_AUTH_PATH,
                        :hp_password  => OS_STORAGE_SEC_ACCOUNT_PASSWORD,
                        :hp_username  => OS_STORAGE_SEC_ACCOUNT_USERNAME )
    end
  end
  
  
  
end

# Test-specific hacks of fundamental classes
module HP::Scalene
  class CLI < Thor
  
  private
  
  # override #connection not to look at account files, just use hardcoded
  # test credentials.
  def connection
    Fog::Storage.new( :provider     => 'HP',
                      :hp_host      => OS_STORAGE_HOST,
                      :hp_port      => OS_STORAGE_PORT,
                      :hp_auth_path => OS_STORAGE_AUTH_PATH,
                      :hp_password  => OS_STORAGE_ACCOUNT_PASSWORD,
                      :hp_username  => OS_STORAGE_ACCOUNT_USERNAME )
  end
  
  end
end
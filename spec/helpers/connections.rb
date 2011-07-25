

RSpec.configure do |config|
  
  # Create a new Storage service connection - maybe memoize later
  def storage_connection(user = :primary)
    if user == :primary
      Fog::Storage.new( :provider      => 'HP',
                        :hp_account_id => OS_STORAGE_ACCOUNT_USERNAME,
                        :hp_secret_key => OS_STORAGE_ACCOUNT_PASSWORD,
                        :hp_auth_uri   => OS_STORAGE_AUTH_URL )
    elsif (user == :secondary)
      Fog::Storage.new( :provider      => 'HP',
                        :hp_account_id => OS_STORAGE_SEC_ACCOUNT_USERNAME,
                        :hp_secret_key => OS_STORAGE_SEC_ACCOUNT_PASSWORD,
                        :hp_auth_uri   => OS_STORAGE_AUTH_URL )
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
    Fog::Storage.new( :provider      => 'HP',
                      :hp_account_id => OS_STORAGE_ACCOUNT_USERNAME,
                      :hp_secret_key => OS_STORAGE_ACCOUNT_PASSWORD,
                      :hp_auth_uri   => OS_STORAGE_AUTH_URL )
  end
  
  end
end


RSpec.configure do |config|
  
  # Create a new Storage service connection - maybe memoize later
  def storage_connection(user = :primary)
    if user == :primary
      Fog::Storage.new( :provider => 'HPScalene',
                        :hp_access_id =>  KVS_ACCESS_ID,
                        :hp_secret_key => KVS_SECRET_KEY,
                        :hp_account_id => KVS_ACCOUNT_ID,
                        :host => KVS_HOST,
                        :port => KVS_PORT )
    elsif user == :secondary
      Fog::Storage.new( :provider => 'HPScalene',
                        :hp_access_id =>  SEC_KVS_ACCESS_ID,
                        :hp_secret_key => SEC_KVS_SECRET_KEY,
                        :hp_account_id => SEC_KVS_ACCOUNT_ID,
                        :host => KVS_HOST,
                        :port => KVS_PORT )
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
    Fog::Storage.new( :provider => 'HPScalene',
                      :hp_access_id =>  KVS_ACCESS_ID,
                      :hp_secret_key => KVS_SECRET_KEY,
                      :hp_account_id => KVS_ACCOUNT_ID,
                      :host => KVS_HOST,
                      :port => KVS_PORT )
  end
  
  end
end
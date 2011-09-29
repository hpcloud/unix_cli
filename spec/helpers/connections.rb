

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
  
  def compute_connection
    Fog::Compute.new( :provider              => 'AWS',
                      :aws_access_key_id     => EC2_COMPUTE_ACCOUNT_USERNAME,
                      :aws_secret_access_key => EC2_COMPUTE_ACCOUNT_PASSWORD,
                      :endpoint              => EC2_COMPUTE_AUTH_URL )
    #Fog::Compute.new( :provider               => 'HP',
    #                  :hp_account_id          => OS_COMPUTE_ACCOUNT_USERNAME,
    #                  :hp_secret_key          => OS_COMPUTE_ACCOUNT_PASSWORD,
    #                  :hp_auth_uri            => OS_COMPUTE_AUTH_URL )
  end

  
end

# Test-specific hacks of fundamental classes
module HP::Cloud
  class CLI < Thor
  
    private

    # override #connection not to look at account files, just use hardcoded
    # test credentials.
    def connection(service = :storage)
      if service == :storage
        Fog::Storage.new( :provider      => 'HP',
                          :hp_account_id => OS_STORAGE_ACCOUNT_USERNAME,
                          :hp_secret_key => OS_STORAGE_ACCOUNT_PASSWORD,
                          :hp_auth_uri   => OS_STORAGE_AUTH_URL )
      else
        Fog::Compute.new( :provider              => 'AWS',
                          :aws_access_key_id     => EC2_COMPUTE_ACCOUNT_USERNAME,
                          :aws_secret_access_key => EC2_COMPUTE_ACCOUNT_PASSWORD,
                          :endpoint              => EC2_COMPUTE_AUTH_URL )
        #Fog::Compute.new( :provider               => 'HP',
        #                  :hp_account_id          => OS_COMPUTE_ACCOUNT_USERNAME,
        #                  :hp_secret_key          => OS_COMPUTE_ACCOUNT_PASSWORD,
        #                  :hp_auth_uri            => OS_COMPUTE_AUTH_URL )
      end
    end
  
  end
end
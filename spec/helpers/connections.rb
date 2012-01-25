

RSpec.configure do |config|
  
  # Create a new Storage service connection - maybe memoize later
  def storage_connection(user = :primary, options = {})
  # Set connection options For more details see excon-ver/lib/excon/connection.rb
    connection_options = {:connect_timeout => options[:connect_timeout] || 5,
                        :read_timeout    => options[:read_timeout] || 5,
                        :write_timeout   => options[:write_timeout] || 5}
    if user == :primary
      Fog::Storage.new( :provider        => 'HP',
                        :connection_options => connection_options,
                        :hp_account_id   => OS_STORAGE_ACCOUNT_USERNAME,
                        :hp_secret_key   => OS_STORAGE_ACCOUNT_PASSWORD,
                        :hp_auth_uri     => OS_STORAGE_AUTH_URL,
                        :hp_tenant_id    => OS_STORAGE_ACCOUNT_TENANT_ID)
    elsif (user == :secondary)
      Fog::Storage.new( :provider        => 'HP',
                        :connection_options => connection_options,
                        :hp_account_id   => OS_STORAGE_SEC_ACCOUNT_USERNAME,
                        :hp_secret_key   => OS_STORAGE_SEC_ACCOUNT_PASSWORD,
                        :hp_auth_uri     => OS_STORAGE_AUTH_URL,
                        :hp_tenant_id    => OS_STORAGE_SEC_ACCOUNT_TENANT_ID)
    end
  end
  
  def compute_connection(options = {})
    connection_options = {:connect_timeout => options[:connect_timeout] || 5,
                        :read_timeout    => options[:read_timeout] || 5,
                        :write_timeout   => options[:write_timeout] || 5}
    Fog::Compute.new( :provider        => 'HP',
                      :connection_options => connection_options,
                      :hp_account_id   => OS_COMPUTE_ACCOUNT_USERNAME,
                      :hp_secret_key   => OS_COMPUTE_ACCOUNT_PASSWORD,
                      :hp_auth_uri     => OS_COMPUTE_AUTH_URL,
                      :hp_tenant_id    => OS_COMPUTE_ACCOUNT_TENANT_ID)
  end
  
end

# Test-specific hacks of fundamental classes
module HP::Cloud
  class CLI < Thor
  
    private

    # override #connection not to look at account files, just use hardcoded
    # test credentials.
    def connection(service = :storage, options = {})
      connection_options = {:connect_timeout => options[:connect_timeout] || 5,
                          :read_timeout    => options[:read_timeout] || 5,
                          :write_timeout   => options[:write_timeout] || 5}
      if service == :storage
        Fog::Storage.new( :provider        => 'HP',
                          :connection_options => connection_options,
                          :hp_account_id   => OS_STORAGE_ACCOUNT_USERNAME,
                          :hp_secret_key   => OS_STORAGE_ACCOUNT_PASSWORD,
                          :hp_auth_uri     => OS_STORAGE_AUTH_URL,
                          :hp_tenant_id    => OS_STORAGE_ACCOUNT_TENANT_ID)
      else
        Fog::Compute.new( :provider        => 'HP',
                          :connection_options => connection_options,
                          :hp_account_id   => OS_COMPUTE_ACCOUNT_USERNAME,
                          :hp_secret_key   => OS_COMPUTE_ACCOUNT_PASSWORD,
                          :hp_auth_uri     => OS_COMPUTE_AUTH_URL,
                          :hp_tenant_id    => OS_COMPUTE_ACCOUNT_TENANT_ID)
      end
    end
  
  end
end
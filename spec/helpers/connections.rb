

RSpec.configure do |config|
  
  # Create a new Storage service connection - maybe memoize later
  def storage_connection(user = :primary, options = {})
  # Set connection options For more details see excon-ver/lib/excon/connection.rb
    if user == :primary
      Fog::Storage.new( :provider        => 'HP',
                        :connection_options => test_connection_options,
                        :hp_account_id   => OS_STORAGE_ACCOUNT_USERNAME,
                        :hp_secret_key   => OS_STORAGE_ACCOUNT_PASSWORD,
                        :hp_auth_uri     => OS_STORAGE_AUTH_URL,
                        :hp_tenant_id    => OS_STORAGE_ACCOUNT_TENANT_ID,
                        :hp_avl_zone     => options[:availability_zone] || OS_STORAGE_ACCOUNT_AVL_ZONE)
    elsif (user == :secondary)
      Fog::Storage.new( :provider        => 'HP',
                        :connection_options => test_connection_options,
                        :hp_account_id   => OS_STORAGE_SEC_ACCOUNT_USERNAME,
                        :hp_secret_key   => OS_STORAGE_SEC_ACCOUNT_PASSWORD,
                        :hp_auth_uri     => OS_STORAGE_AUTH_URL,
                        :hp_tenant_id    => OS_STORAGE_SEC_ACCOUNT_TENANT_ID,
                        :hp_avl_zone     => options[:availability_zone] || OS_STORAGE_SEC_ACCOUNT_AVL_ZONE)
    end
  end
  
  def compute_connection(options = {})
    Fog::Compute.new( :provider        => 'HP',
                      :connection_options => test_connection_options,
                      :hp_account_id   => OS_COMPUTE_ACCOUNT_USERNAME,
                      :hp_secret_key   => OS_COMPUTE_ACCOUNT_PASSWORD,
                      :hp_auth_uri     => OS_COMPUTE_AUTH_URL,
                      :hp_tenant_id    => OS_COMPUTE_ACCOUNT_TENANT_ID,
                      :hp_avl_zone     => options[:availability_zone] || OS_COMPUTE_ACCOUNT_AVL_ZONE)
  end

  def cdn_connection(options = {})
    Fog::CDN.new( :provider        => 'HP',
                      :connection_options => test_connection_options,
                      :hp_account_id   => OS_STORAGE_ACCOUNT_USERNAME,
                      :hp_secret_key   => OS_STORAGE_ACCOUNT_PASSWORD,
                      :hp_auth_uri     => OS_STORAGE_AUTH_URL,
                      :hp_tenant_id    => OS_STORAGE_ACCOUNT_TENANT_ID,
                      :hp_avl_zone     => options[:availability_zone] || OS_STORAGE_ACCOUNT_AVL_ZONE)
  end

  def test_connection_options(options={})
    # define default connection options
    {
        :connect_timeout => options[:connect_timeout] || 5,
        :read_timeout    => options[:read_timeout] || 5,
        :write_timeout   => options[:write_timeout] || 5,
        :ssl_verify_peer => options[:ssl_verify_peer] || false,
        :ssl_ca_path     => options[:ssl_ca_path],
        :ssl_ca_file     => options[:ssl_ca_file]
    }
  end

end

# Test-specific hacks of fundamental classes
module HP::Cloud
  class CLI < Thor
  
    private

    #override #connection not to look at account files, just use hardcoded
    #test credentials.
    def connection(service = :storage, options={})
      begin
        if service == :storage
          Fog::Storage.new( :provider        => 'HP',
                            :connection_options => default_connection_options,
                            :hp_account_id   => OS_STORAGE_ACCOUNT_USERNAME,
                            :hp_secret_key   => OS_STORAGE_ACCOUNT_PASSWORD,
                            :hp_auth_uri     => OS_STORAGE_AUTH_URL,
                            :hp_tenant_id    => OS_STORAGE_ACCOUNT_TENANT_ID,
                            :hp_avl_zone     => options[:availability_zone] || OS_STORAGE_ACCOUNT_AVL_ZONE)
        elsif service == :compute
          Fog::Compute.new( :provider        => 'HP',
                            :connection_options => default_connection_options,
                            :hp_account_id   => OS_COMPUTE_ACCOUNT_USERNAME,
                            :hp_secret_key   => OS_COMPUTE_ACCOUNT_PASSWORD,
                            :hp_auth_uri     => OS_COMPUTE_AUTH_URL,
                            :hp_tenant_id    => OS_COMPUTE_ACCOUNT_TENANT_ID,
                            :hp_avl_zone     => options[:availability_zone] || OS_COMPUTE_ACCOUNT_AVL_ZONE)
        elsif service == :cdn
          Fog::CDN.new( :provider        => 'HP',
                            :connection_options => default_connection_options,
                            :hp_account_id   => OS_STORAGE_ACCOUNT_USERNAME,
                            :hp_secret_key   => OS_STORAGE_ACCOUNT_PASSWORD,
                            :hp_auth_uri     => OS_STORAGE_AUTH_URL,
                            :hp_tenant_id    => OS_STORAGE_ACCOUNT_TENANT_ID,
                            :hp_avl_zone     => options[:availability_zone] || OS_STORAGE_ACCOUNT_AVL_ZONE)
        end
      rescue Exception => e
        raise Fog::HP::Errors::ServiceError, "Please check your HP Cloud Services account to make sure the '#{service.to_s.capitalize!}' service is activated for the appropriate availability zone.\n Exception: #{e}"
      end

    end

    def default_connection_options(options={})
      # define default connection options
      {
          :connect_timeout => options[:connect_timeout] || Config::CONNECT_TIMEOUT,
          :read_timeout    => options[:read_timeout] || Config::READ_TIMEOUT,
          :write_timeout   => options[:write_timeout] || Config::WRITE_TIMEOUT,
          :ssl_verify_peer => options[:ssl_verify_peer] || false,
          :ssl_ca_path     => options[:ssl_ca_path],
          :ssl_ca_file     => options[:ssl_ca_file]
      }
    end
  end
end
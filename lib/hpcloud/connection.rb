
module HP
  module Cloud
    class Connection
    
      VALID_SERVICE_NAMES = ['storage','compute','cdn']

      def initialize
        @storage_connection = nil
        @compute_connection = nil
        @cdn_connection = nil
      end
      @@instance = Connection.new
      private_class_method :new
 
      def self.instance
        return @@instance
      end
 
      def storage(options = {})
        return connection(:storage, options)
      end

      def compute(options = {})
        return connection(:compute, options)
      end

      def cdn(options = {})
        return connection(:cdn, options)
      end

      def connection(service = :storage, options = {})
        begin
        if service == :storage
          storage_connection(options)
        elsif service == :compute
          compute_connection(options)
        elsif service == :cdn
          cdn_connection(options)
        end
        rescue Exception => e
          raise Fog::HP::Errors::ServiceError, "Please check your HP Cloud Services account to make sure the '#{service.to_s.capitalize!}' service is activated for the appropriate availability zone.\n Exception: #{e}"
        end
      end

      def storage_connection(options = {})
        return @storage_connection if @storage_connection
        storage_credentials = Config.current_credentials
        if storage_credentials
          @storage_connection ||= connection_with(:storage, storage_credentials, options)
        else
          raise Fog::Storage::HP::Error, "Error in connecting to the Storage service. Please check your HP Cloud Services account to make sure the account credentials are correct."
        end
      end

      def compute_connection(options = {})
        return @compute_connection if @compute_connection
        compute_credentials = Config.current_credentials
        if compute_credentials
          @compute_connection ||= connection_with(:compute, compute_credentials, options)
        else
          raise Fog::Compute::HP::Error, "Error in connecting to the Compute service. Please check your HP Cloud Services account to make sure the account credentials are correct."
        end
      end

      def cdn_connection(options = {})
        return @cdn_connection if @cdn_connection
        cdn_credentials = Config.current_credentials
        if cdn_credentials
          @cdn_connection ||= connection_with(:cdn, cdn_credentials, options)
        else
          raise Fog::CDN::HP::Error, "Error in connecting to the CDN service. Please check your HP Cloud Services account to make sure the account credentials are correct."
        end
      end

      def connection_with(service, service_credentials, options={})
        connection_options = {:connect_timeout => Config.settings[:connect_timeout] || Config::CONNECT_TIMEOUT,
                              :read_timeout    => Config.settings[:read_timeout]    || Config::READ_TIMEOUT,
                              :write_timeout   => Config.settings[:write_timeout]   || Config::WRITE_TIMEOUT,
                              :ssl_verify_peer => Config.settings[:ssl_verify]      || false,
                              :ssl_ca_path     => Config.settings[:ssl_ca_path]     || nil,
                              :ssl_ca_file     => Config.settings[:ssl_ca_file]     || nil}
        if service == :storage
          Fog::Storage.new( :provider        => 'HP',
                            :connection_options => connection_options,
                            :hp_account_id   => service_credentials[:account_id],
                            :hp_secret_key   => service_credentials[:secret_key],
                            :hp_auth_uri     => service_credentials[:auth_uri],
                            :hp_tenant_id    => service_credentials[:tenant_id],
                            :hp_avl_zone     => options[:availability_zone] || Config.settings[:storage_availability_zone])
        elsif service == :compute
          Fog::Compute.new( :provider        => 'HP',
                            :connection_options => connection_options,
                            :hp_account_id   => service_credentials[:account_id],
                            :hp_secret_key   => service_credentials[:secret_key],
                            :hp_auth_uri     => service_credentials[:auth_uri],
                            :hp_tenant_id    => service_credentials[:tenant_id],
                            :hp_avl_zone     => options[:availability_zone] || Config.settings[:compute_availability_zone])
        elsif service == :cdn
          Fog::CDN.new( :provider            => 'HP',
                            :connection_options => connection_options,
                            :hp_account_id   => service_credentials[:account_id],
                            :hp_secret_key   => service_credentials[:secret_key],
                            :hp_auth_uri     => service_credentials[:auth_uri],
                            :hp_tenant_id    => service_credentials[:tenant_id],
                            :hp_avl_zone     => options[:availability_zone] || Config.settings[:cdn_availability_zone])
        end
      end

      def validate_account(account_credentials)
        connection_options = {:connect_timeout => Config.settings[:connect_timeout] || Config::CONNECT_TIMEOUT,
                              :read_timeout    => Config.settings[:read_timeout]    || Config::READ_TIMEOUT,
                              :write_timeout   => Config.settings[:write_timeout]   || Config::WRITE_TIMEOUT,
                              :ssl_verify_peer => Config.settings[:ssl_verify]      || false,
                              :ssl_ca_path     => Config.settings[:ssl_ca_path]     || nil,
                              :ssl_ca_file     => Config.settings[:ssl_ca_file]     || nil}
        options = {
            :hp_account_id   => account_credentials[:account_id],
            :hp_secret_key   => account_credentials[:secret_key],
            :hp_auth_uri     => account_credentials[:auth_uri],
            :hp_tenant_id    => account_credentials[:tenant_id]
        }
        # authenticate with Identity service
        Fog::HP.authenticate_v2(options, connection_options)
      end
    end
  end
end

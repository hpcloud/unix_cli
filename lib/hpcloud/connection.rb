require 'fog/hp'
require 'fog/block_storage'

module HP
  module Cloud
    class Connection
    
      VALID_SERVICE_NAMES = ['storage','compute','cdn', 'block']

      def initialize
        @storage_connection = {}
        @compute_connection = {}
        @block_connection = {}
        @cdn_connection = {}
        @options = {}
      end
      @@instance = Connection.new
      private_class_method :new
 
      def self.instance
        return @@instance
      end
 
      def reset_connections
        @storage_connection = {}
        @compute_connection = {}
        @block_connection = {}
        @cdn_connection = {}
      end

      def set_options(options)
        if options.nil?
          @options = {}
          return
        end
        if (@options[:availability_zone] != options[:availability_zone])
          reset_connections()
        end
        @options = options
      end

      def storage(account='default')
        return @storage_connection[account] unless @storage_connection[account].nil?
        begin
          @storage_connection[account] = Fog::Storage.new(create_options(account, :storage_availability_zone))
        rescue Exception => e
          raise Fog::HP::Errors::ServiceError, "Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n Exception: #{e}"
        end
      end

      def compute(account='default')
        return @compute_connection[account] unless @compute_connection[account].nil?
        begin
          @compute_connection[account] = Fog::Compute.new(create_options(account, :compute_availability_zone))
        rescue Exception => e
          raise Fog::HP::Errors::ServiceError, "Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n Exception: #{e}"
        end
      end

      def block(account='default')
        return @block_connection[account] unless @block_connection[account].nil?
        begin
          @block_connection[account] = Fog::BlockStorage.new(create_options(account, :block_availability_zone))
        rescue Exception => e
          raise Fog::HP::Errors::ServiceError, "Please check your HP Cloud Services account to make sure the 'BlockStorage' service is activated for the appropriate availability zone.\n Exception: #{e}"
        end
      end

      def cdn(account='default')
        return @cdn_connection[account] unless @cdn_connection[account].nil?
        begin
          @cdn_connection[account] = Fog::CDN.new(create_options(account, :cdn_availability_zone))
        rescue Exception => e
          raise Fog::HP::Errors::ServiceError, "Please check your HP Cloud Services account to make sure the 'CDN' service is activated for the appropriate availability zone.\n Exception: #{e}"
        end
      end

      def create_options(account, zone)
        service_credentials = Config.current_credentials(account)
        if service_credentials.nil?
          raise Fog::Storage::HP::Error, "Error getting service credentials. Please check your HP Cloud Services account to make sure the account credentials are correct."
        end
        zone = @options[:availability_zone] || Config.settings[zone]
        return { :provider => 'HP',
                 :connection_options => Config.connection_options(),
                 :hp_account_id   => service_credentials[:account_id],
                 :hp_secret_key   => service_credentials[:secret_key],
                 :hp_auth_uri     => service_credentials[:auth_uri],
                 :hp_tenant_id    => service_credentials[:tenant_id],
                 :hp_avl_zone     => zone,
                 :user_agent => "HPCloud-UnixCLI/#{HP::Cloud::VERSION}"
               }
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
            :hp_tenant_id    => account_credentials[:tenant_id],
            :user_agent      => "HPCloud-UnixCLI/#{HP::Cloud::VERSION}"
        }
        # authenticate with Identity service
        Fog::HP.authenticate_v2(options, connection_options)
      end
    end
  end
end

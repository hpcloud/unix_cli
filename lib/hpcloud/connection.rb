require 'fog/hp'
require 'fog/block_storage'

module HP
  module Cloud
    class Connection
    
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
 
      VALID_SERVICES = ['storage','compute','cdn', 'block']

      def self.is_service(name)
        return VALID_SERVICES.include?(name)
      end

      def self.get_services()
        return VALID_SERVICES.join(', ')
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
        acct = Accounts.new.get(account)
        avl_zone = @options[:availability_zone] || acct[:zones][zone]
        return { :provider => 'HP',
                 :connection_options => acct[:options],
                 :hp_account_id   => acct[:credentials][:account_id],
                 :hp_secret_key   => acct[:credentials][:secret_key],
                 :hp_auth_uri     => acct[:credentials][:auth_uri],
                 :hp_tenant_id    => acct[:credentials][:tenant_id],
                 :hp_avl_zone     => avl_zone,
                 :user_agent => "HPCloud-UnixCLI/#{HP::Cloud::VERSION}"
               }
      end

      def validate_account(account_credentials)
        options = {
            :hp_account_id   => account_credentials[:account_id],
            :hp_secret_key   => account_credentials[:secret_key],
            :hp_auth_uri     => account_credentials[:auth_uri],
            :hp_tenant_id    => account_credentials[:tenant_id],
            :user_agent      => "HPCloud-UnixCLI/#{HP::Cloud::VERSION}"
        }
        # authenticate with Identity service
        Fog::HP.authenticate_v2(options, Config.default_options)
      end
    end
  end
end

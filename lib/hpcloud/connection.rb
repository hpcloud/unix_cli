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

      def clear_options()
        @options = {}
        reset_connections()
      end

      def storage(account_name=nil)
        account = get_account(account_name)
        return @storage_connection[account] unless @storage_connection[account].nil?
        opts = create_options(account, :storage_availability_zone)
        begin
          @storage_connection[account] = Fog::Storage.new(opts)
        rescue Exception => e
          respo = ErrorResponse.new(e).to_s
          raise Fog::HP::Errors::ServiceError, "Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n Exception: #{respo}"
        end
      end

      def compute
        account = get_account()
        return @compute_connection[account] unless @compute_connection[account].nil?
        opts = create_options(account, :compute_availability_zone)
        begin
          @compute_connection[account] = Fog::Compute.new(opts)
        rescue Exception => e
          raise Fog::HP::Errors::ServiceError, "Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n Exception: #{e}"
        end
      end

      def block
        account = get_account()
        return @block_connection[account] unless @block_connection[account].nil?
        opts = create_options(account, :block_availability_zone)
        begin
          @block_connection[account] = Fog::BlockStorage.new(opts)
        rescue Exception => e
          raise Fog::HP::Errors::ServiceError, "Please check your HP Cloud Services account to make sure the 'BlockStorage' service is activated for the appropriate availability zone.\n Exception: #{e}"
        end
      end

      def cdn
        account = get_account()
        return @cdn_connection[account] unless @cdn_connection[account].nil?
        opts = create_options(account, :cdn_availability_zone)
        begin
          @cdn_connection[account] = Fog::CDN.new(opts)
        rescue Exception => e
          raise Fog::HP::Errors::ServiceError, "Please check your HP Cloud Services account to make sure the 'CDN' service is activated for the appropriate availability zone.\n Exception: #{e}"
        end
      end

      def get_account(account_name = nil)
        return account_name unless account_name.nil?
        return @options[:account_name] || Config.new.get(:default_account) || 'hp'
      end

      def create_options(account_name, zone)
        creds, zones, options = Accounts.new.creds_zones_options(account_name)
        avl_zone = @options[:availability_zone] || zones[zone]
        return { :provider => 'HP',
                 :connection_options => options,
                 :hp_account_id   => creds[:account_id],
                 :hp_secret_key   => creds[:secret_key],
                 :hp_auth_uri     => creds[:auth_uri],
                 :hp_tenant_id    => creds[:tenant_id],
                 :hp_avl_zone     => avl_zone,
                 :user_agent => "HPCloud-UnixCLI/#{HP::Cloud::VERSION}"
               }
      end

      def validate_account(account_credentials)
        options = Config.default_options.clone
        options[:hp_account_id] = account_credentials[:account_id]
        options[:hp_secret_key] = account_credentials[:secret_key]
        options[:hp_auth_uri] = account_credentials[:auth_uri]
        options[:hp_tenant_id] = account_credentials[:tenant_id]
        options[:user_agent] = "HPCloud-UnixCLI/#{HP::Cloud::VERSION}"
        if options[:hp_auth_uri].match(/hpcloud.net/)
          options[:ssl_verify_peer] = false
        end
        Fog::HP.authenticate_v2(options, options)
      end
    end
  end
end

require 'fog/hp'
require 'hpcloud/auth_cache'

module HP
  module Cloud
    class Connection
    
      def initialize
        @storage_connection = {}
        @compute_connection = {}
        @block_connection = {}
        @cdn_connection = {}
        @authcache = HP::Cloud::AuthCache.new
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
        opts[:credentials] = @authcache.get(account)
        begin
          @storage_connection[account] = Fog::Storage.new(opts)
          if @storage_connection[account].respond_to? :credentials
            @authcache.set(account, @storage_connection[account].credentials)
          end
        rescue Exception => e
          @authcache.remove(account)
          respo = ErrorResponse.new(e).to_s
          raise Fog::HP::Errors::ServiceError, "Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n Exception: #{respo}"
        end
        return @storage_connection[account]
      end

      def compute
        account = get_account()
        return @compute_connection[account] unless @compute_connection[account].nil?
        opts = create_options(account, :compute_availability_zone)
        opts[:credentials] = @authcache.get(account)
        begin
          @compute_connection[account] = Fog::Compute.new(opts)
          if @compute_connection[account].respond_to? :credentials
            @authcache.set(account, @compute_connection[account].credentials)
          end
        rescue Exception => e
          @authcache.remove(account)
          raise Fog::HP::Errors::ServiceError, "Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n Exception: #{e}"
        end
        return @compute_connection[account]
      end

      def block
        account = get_account()
        return @block_connection[account] unless @block_connection[account].nil?
        opts = create_options(account, :block_availability_zone)
        opts.delete(:provider)
        opts[:credentials] = @authcache.get(account)
        begin
          @block_connection[account] = Fog::HP::BlockStorage.new(opts)
          if @block_connection[account].respond_to? :credentials
            @authcache.set(account, @block_connection[account].credentials)
          end
        rescue Exception => e
          @authcache.remove(account)
          raise Fog::HP::Errors::ServiceError, "Please check your HP Cloud Services account to make sure the 'BlockStorage' service is activated for the appropriate availability zone.\n Exception: #{e}"
        end
        return @block_connection[account]
      end

      def cdn
        account = get_account()
        return @cdn_connection[account] unless @cdn_connection[account].nil?
        opts = create_options(account, :cdn_availability_zone)
        opts[:credentials] = @authcache.get(account)
        begin
          @cdn_connection[account] = Fog::CDN.new(opts)
          if @cdn_connection[account].respond_to? :credentials
            @authcache.set(account, @cdn_connection[account].credentials)
          end
        rescue Exception => e
          @authcache.remove(account)
          raise Fog::HP::Errors::ServiceError, "Please check your HP Cloud Services account to make sure the 'CDN' service is activated for the appropriate availability zone.\n Exception: #{e}"
        end
        return @cdn_connection[account]
      end

      def get_account(account_name = nil)
        return account_name unless account_name.nil?
        return @options[:account_name] || Config.new.get(:default_account) || 'hp'
      end

      def create_options(account_name, zone)
        return Accounts.new.create_options(account_name, zone, @options[:availability_zone])
      end

      def validate_account(account_name)
        options = create_options(account_name, nil)
        case options[:provider]
        when "hp"
          unless options[:connection_options].nil?
            options[:ssl_verify_peer] = options[:connection_options][:ssl_verify_peer]
          end
          Fog::HP.authenticate_v2(options, options[:connection_options])
        else
          Fog::Storage.new(options).directories
          return true
        end
      end
    end
  end
end

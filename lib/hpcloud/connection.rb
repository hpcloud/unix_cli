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
        @network_connection = {}
        @dns_connection = {}
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
        @network_connection = {}
        @dns_connection = {}
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

      def read_creds(account, opts, service)
        creds = @authcache.read(account)
        if creds.nil?
          return unless opts[:provider] == "hp"
          creds = validate_account(account)
          return if creds.nil?
          @authcache.write(account, creds)
        end
        if opts[:hp_avl_zone].nil?
          opts[:hp_avl_zone] = @authcache.default_zone(account, service)
        end
        opts[:credentials] = creds
      end

      def write_creds(account, connection)
        if connection.respond_to? :credentials
          @authcache.write(account, connection.credentials)
        end
      end

      def storage(account_name=nil)
        account = get_account(account_name)
        return @storage_connection[account] unless @storage_connection[account].nil?
        opts = create_options(account, :storage_availability_zone)
        read_creds(account, opts, 'Object Storage')
        begin
          @storage_connection[account] = Fog::Storage.new(opts)
          write_creds(account, @storage_connection[account])
        rescue Exception => e
          @authcache.remove(account)
          respo = ErrorResponse.new(e).to_s
          raise Fog::HP::Errors::ServiceError, "Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n Exception: #{respo}\n Print the service catalog: hpcloud account:catalog #{account}"
        end
        return @storage_connection[account]
      end

      def compute
        account = get_account()
        return @compute_connection[account] unless @compute_connection[account].nil?
        opts = create_options(account, :compute_availability_zone)
        read_creds(account, opts, 'Compute')
        begin
          @compute_connection[account] = Fog::Compute.new(opts)
          write_creds(account, @compute_connection[account])
        rescue Exception => e
          @authcache.remove(account)
          raise Fog::HP::Errors::ServiceError, "Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n Exception: #{e}\n Print the service catalog: hpcloud account:catalog #{account}"
        end
        return @compute_connection[account]
      end

      def block
        account = get_account()
        return @block_connection[account] unless @block_connection[account].nil?
        opts = create_options(account, :block_availability_zone)
        opts.delete(:provider)
        read_creds(account, opts, 'Block Storage')
        begin
          @block_connection[account] = Fog::HP::BlockStorage.new(opts)
          write_creds(account, @block_connection[account])
        rescue Exception => e
          @authcache.remove(account)
          raise Fog::HP::Errors::ServiceError, "Please check your HP Cloud Services account to make sure the 'BlockStorage' service is activated for the appropriate availability zone.\n Exception: #{e}\n Print the service catalog: hpcloud account:catalog #{account}"
        end
        return @block_connection[account]
      end

      def cdn
        account = get_account()
        return @cdn_connection[account] unless @cdn_connection[account].nil?
        opts = create_options(account, :cdn_availability_zone)
        read_creds(account, opts, 'CDN')
        begin
          @cdn_connection[account] = Fog::CDN.new(opts)
          write_creds(account, @cdn_connection[account])
        rescue Exception => e
          @authcache.remove(account)
          raise Fog::HP::Errors::ServiceError, "Please check your HP Cloud Services account to make sure the 'CDN' service is activated for the appropriate availability zone.\n Exception: #{e}\n Print the service catalog: hpcloud account:catalog #{account}"
        end
        return @cdn_connection[account]
      end

      def network
        account = get_account()
        return @network_connection[account] unless @network_connection[account].nil?
        opts = create_options(account, :network_availability_zone)
        read_creds(account, opts, 'Networking')
        begin
          opts.delete(:provider)
          @network_connection[account] = Fog::HP::Network.new(opts)
          write_creds(account, @network_connection[account])
        rescue Exception => e
          @authcache.remove(account)
          raise Fog::HP::Errors::ServiceError, "Please check your HP Cloud Services account to make sure the 'Network' service is activated for the appropriate availability zone.\n Exception: #{e}\n Print the service catalog: hpcloud account:catalog #{account}"
        end
        return @network_connection[account]
      end

      def dns
        account = get_account()
        return @dns_connection[account] unless @dns_connection[account].nil?
        opts = create_options(account, :dns_availability_zone)
        read_creds(account, opts, 'DNS')
        begin
          opts.delete(:provider)
          @dns_connection[account] = Fog::HP::DNS.new(opts)
          write_creds(account, @dns_connection[account])
        rescue Exception => e
          @authcache.remove(account)
          raise Fog::HP::Errors::ServiceError, "Please check your HP Cloud Services account to make sure the 'DNS' service is activated for the appropriate availability zone.\n Exception: #{e}\n Print the service catalog: hpcloud account:catalog #{account}"
        end
        return @dns_connection[account]
      end

      def get_account(account_name = nil)
        return account_name unless account_name.nil?
        return @options[:account_name] || Config.new.get(:default_account) || 'hp'
      end

      def create_options(account_name, zone)
        return Accounts.new.create_options(account_name, zone, @options[:availability_zone])
      end

      def catalog(name, service)
        begin
          rsp = validate_account(name)
          cata = rsp[:service_catalog]
          unless service.empty?
            hsh = {}
            service.each{ |x|
              hsh[x.to_sym] = cata[x.to_sym]
            }
            cata = hsh
          end
          return cata.to_yaml.gsub(/--- \n/,'').gsub(/\{\}/,'').gsub(/\n\n/, "\n")
        rescue
        end
        return ""
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

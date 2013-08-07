require 'yaml'

module HP
  module Cloud
    class Accounts
      attr_reader :directory
      @@home = nil

      DEFAULT_ACCOUNT = "default_account"
      TOP_LEVEL = [:username, :provider]
      CREDENTIALS = [:account_id,
                     :secret_key,
                     :auth_uri,
                     :tenant_id]
      ZONES = [:compute,
               :"object storage",
               :cdn,
               :dns,
               :lbaas,
               :db,
               :network,
               :"block storage"]
      OPTIONS = [:connect_timeout,
                 :read_timeout,
                 :write_timeout,
                 :ssl_verify_peer,
                 :ssl_ca_path,
                 :ssl_ca_file,
                 :preferred_flavor,
                 :preferred_win_image,
                 :preferred_image]

      def initialize
        if @@home.nil?
          @@home = ENV['HOME']
        end
        @directory = @@home + "/.hpcloud/accounts/"
        @accts = {}
      end

      def self.home_directory=(dir)
        @@home = dir
      end

      def self.get_known
        ret = ""
        CREDENTIALS.each{|key| ret += "\n * " + key.to_s }
        ZONES.each{|key| ret += "\n * " + key.to_s }
        OPTIONS.each{|key| ret += "\n * " + key.to_s }
        return ret
      end

      def get_file_name(account)
        "#{@directory}#{account.to_s.downcase.gsub(' ', '_')}"
      end

      def list
        unless File.directory?("#{@directory}")
          return "No such file or directory - #{@directory}\n" +
                 "Run account:setup to create accounts."
        end
        ray = Dir.entries("#{@directory}")
        ray.delete_if{|item| File.file?("#{@directory}/#{item}") == false }
        ray.sort!
        return ray.join("\n")
      end

      def remove(account)
        begin
          file_name = get_file_name(account)
          File.delete(file_name)
          return true
        rescue Exception => e
          raise Exception.new('Error removing account file: ' + file_name)
        end
        return false
      end

      def copy(src, dest)
        begin
          src_name = get_file_name(src)
          dest_name = get_file_name(dest)
          FileUtils.cp(src_name, dest_name)
          return true
        rescue Exception => e
          raise Exception.new('Error copying ' + src_name + ' to ' + dest_name)
        end
        return false
      end

      def read(account, createIt=false)
        return @accts[account] if @accts[account].nil? == false
        file_name = get_file_name(account)
        if account == 'hp' && File.exists?(file_name) == false
          migrate
        end
        if File.exists?(file_name)
          begin
            hsh = YAML::load(File.open(file_name))
            hsh[:credentials] = {} if hsh[:credentials].nil?
            if ((hsh[:zones].nil? == false) && (hsh[:regions].nil? == true))
              regions = {}
              zones = hsh[:zones]
              regions[:compute] = zones[:compute_availability_zone] unless zones[:compute_availability_zone].nil?
              regions[:"object storage"] = zones[:storage_availability_zone] unless zones[:storage_availability_zone].nil?
              regions[:cdn] = zones[:cdn_availability_zone] unless zones[:cdn_availability_zone].nil?
              regions[:"block storage"] = zones[:block_availability_zone] unless zones[:block_availability_zone].nil?
              hsh[:zones] = nil
              hsh[:regions] = regions
            end
            hsh[:regions] = {} if hsh[:regions].nil?
            hsh[:options] = {} if hsh[:options].nil?
            @accts[account] = hsh
          rescue Exception => e
            raise Exception.new('Error reading account file: ' + file_name)
          end
        else
          if createIt
            return create(account)
          end
          raise Exception.new('Could not find account file: ' + file_name)
        end
        return @accts[account]
      end

      def create(account)
        if @accts[account].nil?
          uri = Config.new.get(:default_auth_uri)
          @accts[account] = {:credentials=>{:auth_uri=>uri},
                             :regions=>{},
                             :options=>{}}
        end
        return @accts[account]
      end

      def set_cred(account, cred)
        if @accts[account].nil?
          @accts[account] = {:credentials=>{}, :regions=>{}, :options=>{}}
        end
        @accts[account][:credentials] = cred
        unless cred[:hp_auth_uri].nil?
          if cred[:hp_auth_uri].match(/hpcloud.net/)
            @accts[account][:options][:ssl_verify_peer] = false
          end
        end
      end

      def set(account, key, value)
        hsh = @accts[account]
        return false if hsh.nil?
        key = key.to_sym
        if CREDENTIALS.include?(key)
          hsh[:credentials][key] = value
        elsif ZONES.include?(key)
          hsh[:regions][key] = value
        elsif OPTIONS.include?(key)
          hsh[:options][key] = value
        elsif TOP_LEVEL.include?(key)
          hsh[key] = value
        else
          return false
        end
        return true
      end

      def get(account)
        hsh = read(account).clone
        settings = Config.new.settings
        hsh[:provider] ||= 'hp'
        hsh[:options][:connect_timeout] ||= settings[:connect_timeout]
        hsh[:options][:read_timeout] ||= settings[:read_timeout]
        hsh[:options][:write_timeout] ||= settings[:write_timeout]
        hsh[:options][:preferred_flavor] ||= settings[:preferred_flavor]
        hsh[:options][:preferred_image] ||= settings[:preferred_image]
        hsh[:options][:connect_timeout] = hsh[:options][:connect_timeout].to_i
        hsh[:options][:read_timeout] = hsh[:options][:read_timeout].to_i
        hsh[:options][:write_timeout] = hsh[:options][:write_timeout].to_i
        if hsh[:options][:ssl_verify_peer].nil?
          hsh[:options][:ssl_verify_peer] = settings[:ssl_verify_peer]
        end
        if hsh[:options][:ssl_verify_peer].to_s == "false" || hsh[:options][:ssl_verify_peer].to_s == "no"
          hsh[:options][:ssl_verify_peer] = false
        else
          hsh[:options][:ssl_verify_peer] = true
        end
        hsh[:options][:ssl_ca_path] ||= settings[:ssl_ca_path]
        hsh[:options][:ssl_ca_path] ||= settings[:ssl_ca_path]
        hsh[:options][:ssl_ca_file] ||= settings[:ssl_ca_file]
        hsh[:options].delete_if{ |k,v| v.nil? }
        return hsh
      end

      def write(account)
        config = @accts[account]
        if config.nil?
          raise Exception.new("Cannot find account information for #{account}")
        end
        file_name = get_file_name(account)
        begin
          FileUtils.mkpath(@directory)
          File.open(file_name, 'w') do |file|
            file.write config.to_yaml
          end
        rescue Exception => e
          raise Exception.new("Error writing file #{file_name}")
        end
      end

      def create_options(account_name, zone, avl_zone = nil)
        hsh = get(account_name)
        provider = hsh[:provider] || 'hp'
        provider = provider.downcase
        creds = hsh[:credentials]
        regions = hsh[:regions] || {}
        opts = hsh[:options]
        opts.delete(:preferred_flavor)
        opts.delete(:preferred_image)
        opts.delete(:preferred_win_image)
        opts.delete(:checker_url)
        opts.delete(:checker_deferment)
        unless zone.nil?
          avl_zone = avl_zone || regions[zone.to_s.downcase.to_sym]
        end

        options = {}
        if provider == 'hp'
          options[:hp_access_key] = creds[:account_id] || creds[:hp_access_key] || creds[:hp_account_id]
          options[:hp_secret_key] = creds[:secret_key] || creds[:hp_secret_key]
          options[:hp_use_upass_auth_style] = true if creds[:userpass] == true
          options[:hp_auth_uri] = creds[:auth_uri] || creds[:hp_auth_uri]
          options[:hp_tenant_id ] = creds[:tenant_id] || creds[:hp_tenant_id]
          options[:hp_avl_zone] = avl_zone
          options[:connection_options] = opts
          options[:user_agent] = "HPCloud-UnixCLI/#{HP::Cloud::VERSION}"
        else
          options = creds
        end
        options[:provider] = provider

        return options
      end

      def migrate
        ray = list
        return false if ray.index('default').nil?
        return false unless ray.index('hp').nil?
        warn "Renaming account 'default' to 'hp'..."
        return false unless copy('default', 'hp')
        remove('default')

        config = Config.new(true)
        config.set(:default_account, 'hp')
        config.write()
        warn "Account 'hp' is now the default"
        return true
      end
    end
  end
end

require 'yaml'

module HP
  module Cloud
    class Accounts
      attr_reader :directory
      @@home = nil

      DEFAULT_ACCOUNT = "default_account"
      TOP_LEVEL = [:username]
      CREDENTIALS = [:account_id,
                     :secret_key,
                     :auth_uri,
                     :tenant_id]
      ZONES = [:compute_availability_zone,
               :storage_availability_zone,
               :cdn_availability_zone,
               :block_availability_zone]
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

      def read(account = 'default', createIt=false)
        return @accts[account] if @accts[account].nil? == false
        file_name = get_file_name(account)
        if File.exists?(file_name)
          begin
            hsh = YAML::load(File.open(file_name))
            hsh[:credentials] = {} if hsh[:credentials].nil?
            hsh[:zones] = {} if hsh[:zones].nil?
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
                             :zones=>{},
                             :options=>{}}
          set_default_zones(@accts[account])
        end
        return @accts[account]
      end

      def set_credentials(account, id, key, uri, tenant)
        if @accts[account].nil?
          @accts[account] = {:credentials=>{}, :zones=>{}, :options=>{}}
        end
        @accts[account][:credentials] = { :account_id => id,
                                          :secret_key => key,
                                          :auth_uri => uri,
                                          :tenant_id => tenant
                                        }
        if uri.match(/hpcloud.net/)
          @accts[account][:options][:ssl_verify_peer] = false
        end
      end

      def set_zones(account, compute, storage, block)
        hsh = @accts[account]
        hsh[:zones][:compute_availability_zone] = compute
        hsh[:zones][:storage_availability_zone] = storage
        hsh[:zones][:block_availability_zone] = block
        set_default_zones(hsh)
        hsh[:zones].delete(:compute_availability_zone) if compute.empty?
        hsh[:zones].delete(:storage_availability_zone) if storage.empty?
        hsh[:zones].delete(:block_availability_zone) if block.empty?
      end

      def set(account, key, value)
        hsh = @accts[account]
        return false if hsh.nil?
        key = key.to_sym
        if CREDENTIALS.include?(key)
          hsh[:credentials][key] = value
        elsif ZONES.include?(key)
          hsh[:zones][key] = value
        elsif OPTIONS.include?(key)
          hsh[:options][key] = value
        elsif TOP_LEVEL.include?(key)
          hsh[key] = value
        else
          return false
        end
        return true
      end

      def set_default_zones(hsh)
        settings = Config.new.settings
        hsh[:zones][:compute_availability_zone] ||= settings[:compute_availability_zone]
        hsh[:zones][:storage_availability_zone] ||= settings[:storage_availability_zone]
        hsh[:zones][:cdn_availability_zone] ||= settings[:cdn_availability_zone]
        hsh[:zones][:block_availability_zone] ||= settings[:block_availability_zone]
      end

      def rejigger_zones(zones)
        compute = zones[:compute_availability_zone]
        alternate = compute
        alternate=compute.gsub(/^[^\.]*\./, '')
        if alternate == compute
          return
        end
        zones[:storage_availability_zone] = alternate
        zones[:cdn_availability_zone] = alternate
        zones[:block_availability_zone] = compute
      end

      def get(account = 'default')
        hsh = read(account).clone
        settings = Config.new.settings
        set_default_zones(hsh)
        hsh[:options][:connect_timeout] ||= settings[:connect_timeout]
        hsh[:options][:read_timeout] ||= settings[:read_timeout]
        hsh[:options][:write_timeout] ||= settings[:write_timeout]
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

      def write(account='default')
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

      def creds_zones_options(name)
        hsh = get(name)
        creds = hsh[:credentials]
        zones = hsh[:zones]
        opts = hsh[:options]
        opts.delete(:preferred_flavor)
        opts.delete(:preferred_image)
        opts.delete(:preferred_win_image)
        opts.delete(:checker_url)
        opts.delete(:checker_deferment)
        return creds, zones, opts
      end
    end
  end
end

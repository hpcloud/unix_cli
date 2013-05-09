require 'yaml'

module HP
  module Cloud
    class Config
      @@home = nil
      attr_reader :directory, :file, :settings
      KNOWN = [ :default_auth_uri,
                :block_availability_zone,
                :storage_availability_zone,
                :compute_availability_zone,
                :cdn_availability_zone,
                :connect_timeout,
                :read_timeout,
                :write_timeout,
                :preferred_flavor,
                :preferred_image,
                :ssl_verify_peer,
                :ssl_ca_path,
                :ssl_ca_file,
                :default_account,
                :storage_page_length,
                :storage_segment_size,
                :storage_chunk_size,
                :storage_max_size,
                :report_page_length,
                :checker_url,
                :checker_deferment
              ]

      def initialize(ignore=false)
        if @@home.nil?
          @@home = ENV['HOME']
        end
        @directory = @@home + "/.hpcloud/"
        @file = @directory + "config.yml"
        @file_settings = {}
        @settings = {}
        begin
          read()
        rescue Exception => e
          if ignore
            warn e.to_s
          else
            raise e
          end
        end
      end

      def self.home_directory=(dir)
        @@home = dir
      end
      
      def self.default_config
        return { :default_auth_uri => 'https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/',
                 :default_account => 'hp'
               }
      end

      def self.default_options
        return { :connect_timeout => 30,
                 :read_timeout => 240,
                 :write_timeout => 240,
                 :preferred_flavor => 100,
                 :ssl_verify_peer => true,
                 :ssl_ca_path => nil,
                 :ssl_ca_file => nil,
                 :default_account => 'hp',
                 :checker_url => 'https://region-a.geo-1.objects.hpcloudsvc.com:443/v1/89388614989714/documentation-downloads/unixcli/latest',
                 :checker_deferment => 604800,
               }
      end

      def self.get_known
        ret = ""
        KNOWN.each{|key| ret += "\n" + key.to_s }
        return ret
      end

      def self.split(nvp)
        begin
          kv = nvp.split('=')
          if kv.length == 2
            return kv[0], kv[1]
          end
          if nvp[-1,1] == '='
            return kv[0], ''
          end
        rescue Exception => e
        end
        raise Exception.new("Invalid name value pair: '#{nvp}'")
      end

      def list
        return @settings.to_yaml.gsub(/---\n/,'').gsub(/^:/,'')
      end

      def read
        cfg = Config.default_config()
        if File.exists?(@file)
          begin
            @file_settings = YAML::load(File.open(@file))
            @settings = @file_settings.clone
            @settings[:block_availability_zone] ||= cfg[:block_availability_zone]
            @settings[:compute_availability_zone] ||= cfg[:compute_availability_zone]
            @settings[:cdn_availability_zone] ||= cfg[:cdn_availability_zone]
            @settings[:storage_availability_zone] ||= cfg[:storage_availability_zone]
          rescue Exception => e
            @settings = cfg
            raise Exception.new("Error reading configuration file: #{@file}\n" + e.to_s)
          end
        else
          @settings = cfg
        end
        options = Config.default_options()
        @settings[:connect_timeout] ||= options[:connect_timeout]
        @settings[:read_timeout] ||= options[:read_timeout]
        @settings[:write_timeout] ||= options[:write_timeout]
        @settings[:preferred_flavor] ||= options[:preferred_flavor]
        @settings[:connect_timeout] = @settings[:connect_timeout].to_i
        @settings[:read_timeout] = @settings[:read_timeout].to_i
        @settings[:write_timeout] = @settings[:write_timeout].to_i
        if @settings[:ssl_verify_peer].nil?
          @settings[:ssl_verify_peer] = options[:ssl_verify_peer]
        end
        if @settings[:ssl_verify_peer].to_s == "false" || @settings[:ssl_verify_peer].to_s == "no"
          @settings[:ssl_verify_peer] = false
        else
          @settings[:ssl_verify_peer] = true
        end
        @settings[:ssl_ca_path] ||= options[:ssl_ca_path]
        @settings[:ssl_ca_file] ||= options[:ssl_ca_file]
        @settings[:default_account] ||= options[:default_account]
        @settings[:checker_url] ||= options[:checker_url]
        @settings[:checker_deferment] ||= options[:checker_deferment]
        @settings[:checker_deferment] = @settings[:checker_deferment].to_i
        @settings.delete_if { |k,v| v.nil? }
      end

      def get(key)
        return @settings[key.to_sym]
      end

      def get_i(key, default_value)
        begin
          value = @settings[key.to_sym].to_i
          return default_value if value == 0
          return value
        rescue
        end
        return default_value
      end

      def set(key, value)
        key = key.to_sym
        if KNOWN.include?(key) == false
          raise Exception.new("Unknown configuration key value '#{key.to_s}'")
        end
        value = value.to_s
        if value.empty?
          if key.to_s.include?('availability_zone')
            raise Exception.new("The value of '#{key.to_s}' may not be empty")
          end
          @file_settings.delete(key)
          @settings.delete(key)
        else
          if key.to_s == 'ssl_verify_peer'
            if value.to_s == "false" || value.to_s == "no"
              value = false
            else
              value = true
            end
          end
          @file_settings[key] = value
          @settings[key] = value
        end
        return true
      end

      def write()
        begin
          Dir.mkdir(@directory) unless File.directory?(@directory)
          @file_settings.delete_if { |k,v| v.nil? }
          File.open("#{@file}", 'w') do |file|
            file.write @file_settings.to_yaml
          end
        rescue
          raise Exception.new('Error writing configuration file: ' + @file)
        end
        return true
      end
    end
  end
end

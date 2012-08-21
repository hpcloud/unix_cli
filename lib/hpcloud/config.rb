require 'yaml'

module HP
  module Cloud
    class Config
      @@home = nil
      attr_reader :directory, :file, :settings

      def initialize
        if @@home.nil?
          @@home = ENV['HOME']
        end
        @directory = @@home + "/.hpcloud/"
        @file = @directory + "config.yml"
        read()
      end

      def self.home_directory=(dir)
        @@home = dir
      end
      
      def self.default_config
        return { :default_auth_uri => 'https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/',
                 :block_availability_zone => 'az-1.region-a.geo-1',
                 :storage_availability_zone => 'region-a.geo-1',
                 :compute_availability_zone => 'az-1.region-a.geo-1',
                 :cdn_availability_zone     => 'region-a.geo-1'
               }
      end

      def self.default_options
        return { :connect_timeout => 30,
                 :read_timeout => 30,
                 :write_timeout => 30,
                 :ssl_verify_peer => false,
                 :ssl_ca_path => nil,
                 :ssl_ca_file => nil
               }
      end

      def read
        cfg = Config.default_config()
        if File.exists?(@file)
          begin
            @file_settings = YAML::load(File.open(@file))
            @settings = @file_settings
            @settings[:block_availability_zone] ||= cfg[:block_availability_zone]
            @settings[:cdn_availability_zone] ||= cfg[:cdn_availability_zone]
            @settings[:compute_availability_zone] ||= cfg[:compute_availability_zone]
            @settings[:storage_availability_zone] ||= cfg[:storage_availability_zone]
          rescue
            raise Exception.new('Error reading configuration file: ' + @file)
          end
        else
          @settings = cfg
        end
        options = Config.default_options()
        @settings[:connect_timeout] ||= options[:connect_timeout]
        @settings[:read_timeout] ||= options[:read_timeout]
        @settings[:write_timeout] ||= options[:write_timeout]
        @settings[:ssl_verify_peer] ||= options[:ssl_verify_peer]
        @settings[:ssl_ca_path] ||= options[:ssl_ca_path]
        @settings[:ssl_ca_file] ||= options[:ssl_ca_file]
      end

      def write()
        return unless @file_settings.empty?
        begin
          Dir.mkdir(@directory) unless File.directory?(@directory)
          File.open("#{@file}", 'w') do |file|
            file.write @file_settings.to_yaml
          end
        rescue
          raise Exception.new('Error writing configuration file: ' + @file)
        end
      end
    end
  end
end

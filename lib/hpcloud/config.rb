require 'yaml'

module HP
  module Cloud
    class Config

      @@default_options = {:connect_timeout => 30,
                           :read_timeout => 30,
                           :write_timeout => 30,
                           :ssl_verify_peer => false,
                           :ssl_ca_path => nil,
                           :ssl_ca_file => nil}


      @@default_config = { :default_auth_uri => 'https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/',
                           :block_availability_zone => 'az-1.region-a.geo-1',
                           :storage_availability_zone => 'region-a.geo-1',
                           :compute_availability_zone => 'az-1.region-a.geo-1',
                           :cdn_availability_zone     => 'region-a.geo-1'
                         }

      def self.config_directory
        home_directory + "/.hpcloud/"
      end
    
      def self.config_file
        config_directory + 'config.yml'
      end
    
      def self.home_directory
        @@home_dir ||= ENV['HOME']
      end
    
      def self.home_directory=(dir)
        @@home_dir = dir # allow overload for testing
      end
      
      def self.reset_home_directory
        @@home_dir = nil
      end
    
      def self.default_options
        return @@default_options
      end

      def self.settings
        ensure_config_exists
        @@settings ||=
          if File.exists?(config_file)
            YAML::load(File.open(config_file))
          else
            @@default_config
          end
        @@settings[:block_availability_zone] ||= 'az-1.region-a.geo-1'
        @@settings[:storage_availability_zone] ||= 'region-a.geo-1'
        @@settings[:compute_availability_zone] ||= 'az-1.region-a.geo-1'
        @@settings[:cdn_availability_zone] ||= 'region-a.geo-1'
        @@settings[:connect_timeout] ||= @@default_options[:connect_timeout]
        @@settings[:read_timeout] ||= @@default_options[:read_timeout]
        @@settings[:write_timeout] ||= @@default_options[:write_timeout]
        @@settings[:ssl_verify_peer] ||= @@default_options[:ssl_verify_peer]
        @@settings[:ssl_ca_path] ||= @@default_options[:ssl_ca_path]
        @@settings[:ssl_ca_file] ||= @@default_options[:ssl_ca_file]
        return @@settings
      end
    
      # force checking for settings on next request
      def self.flush_settings
        @@settings = nil
      end
    
      def self.update_credentials(account, credentials)
        ensure_config_exists
        if account_exists?(account)
          update_account account, credentials
        else
          write_account account, credentials
        end
      end
    
      # Note: May want to port some of this to Thor's native actions eventually?
      def self.ensure_config_exists
        Dir.mkdir(config_directory) unless File.directory?(config_directory)
        unless File.exists?(config_file)
          File.open(config_file, 'w') { |file| file.write @@default_config.to_yaml }
        end
      end

      def self.update_config(settings={})
        unless settings.empty?
          # make sure the config file exists
          ensure_config_exists
          # update the config file with the settings from the settings hash
          config = YAML::load(File.open("#{config_file}"))
          # only update the settings that are changed
          settings.each do |key, value|
            config[key.to_sym] = value
          end
          # write the updated config file back
          File.open("#{config_file}", 'w') do |file|
            file.write config.to_yaml
          end
        end
      end
    end
  end
end

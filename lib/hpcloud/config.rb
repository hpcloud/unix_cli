require 'yaml'

module HP
  module Cloud
    class Config

      # Connection timeouts in secs.
      CONNECT_TIMEOUT = 30
      READ_TIMEOUT = 30
      WRITE_TIMEOUT = 30

      @@default_config = { :default_auth_uri => 'https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/',
                           :block_availability_zone => 'az-1.region-a.geo-1',
                           :storage_availability_zone => 'region-a.geo-1',
                           :compute_availability_zone => 'az-1.region-a.geo-1',
                           :cdn_availability_zone     => 'region-a.geo-1'
                         }
      @@credentials = {}

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
    
      def self.accounts_directory
        config_directory + 'accounts/'
      end

      def self.remove_config_directory
        FileUtils.rm_rf(HP::Cloud::Config.config_directory)
      end

      def self.set_credentials(account, id, key, uri, tenant)
        @@credentials[account] = { :account_id => id,
                                   :secret_key => key,
                                   :auth_uri => uri,
                                   :tenant_id     => tenant
                                 }
      end

      def self.current_credentials(account = 'default')
        return @@credentials[account] if ! @@credentials[account].nil?
        @@credentials[account] = read_credentials(account)
        return @@credentials[account]
      end

      def self.read_credentials(account = 'default')
        if File.exists?(accounts_directory + account)
          return YAML::load(File.open(accounts_directory + 'default'))[:credentials]
        end
        return nil
      end

      def self.connection_options(account = 'default')
        return {
          :connect_timeout => Config.settings[:connect_timeout] || Config::CONNECT_TIMEOUT,
          :read_timeout    => Config.settings[:read_timeout]    || Config::READ_TIMEOUT,
          :write_timeout   => Config.settings[:write_timeout]   || Config::WRITE_TIMEOUT,
          :ssl_verify_peer => Config.settings[:ssl_verify_peer]      || false,
          :ssl_ca_path     => Config.settings[:ssl_ca_path]     || nil,
          :ssl_ca_file     => Config.settings[:ssl_ca_file]     || nil }
      end

      def self.settings
        ensure_config_exists
        @@settings ||=
          if File.exists?(config_file)
            YAML::load(File.open(config_file))
          else
            @@default_config
          end
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
        Dir.mkdir(accounts_directory) unless File.directory?(accounts_directory)
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

      def self.write_account(account_name, credentials)
        contents = {:credentials => credentials}
        File.open("#{accounts_directory}#{account_name.to_s.downcase.gsub(' ', '_')}", 'w') do |file|
          file.write contents.to_yaml
        end
      end

      def self.account_exists?(account_name)
        File.exists?(accounts_directory + account_name.to_s)
      end

      def self.update_account(account_name, credentials)
        creds = YAML::load(File.open("#{accounts_directory}#{account_name.to_s.downcase.gsub(' ', '_')}"))
        # only update the creds that are set
        creds[:credentials] = credentials
        File.open("#{accounts_directory}#{account_name.to_s.downcase.gsub(' ', '_')}", 'w') do |file|
          file.write creds.to_yaml
        end
      end

    end
  end
end

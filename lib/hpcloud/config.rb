require 'yaml'

module HP
  module Cloud
    class Config

      @@default_config = { :default_storage_auth_uri => 'https://region-a.geo-1.objects.hpcloudsvc.com/auth/v1.0/',
                           :default_compute_auth_uri => 'https://az-1.region-a.geo-1.compute.hpcloudsvc.com/v1.1/',
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
    
      def self.accounts_directory
        config_directory + 'accounts/'
      end
    
      def self.current_credentials
        if File.exists?(accounts_directory + 'default')
          return YAML::load(File.open(accounts_directory + 'default'))[:credentials]
        end
        nil
      end

      def self.storage_credentials
        if current_credentials
          return current_credentials[:storage]
        end
        nil
      end

      def self.compute_credentials
        if current_credentials
          return current_credentials[:compute]
        end
        nil
      end

      def self.settings
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
        creds[:credentials][:storage] = credentials[:storage] if credentials.has_key?(:storage)
        creds[:credentials][:compute] = credentials[:compute] if credentials.has_key?(:compute)
        File.open("#{accounts_directory}#{account_name.to_s.downcase.gsub(' ', '_')}", 'w') do |file|
          file.write creds.to_yaml
        end
      end

    end
  end
end
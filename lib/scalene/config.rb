require 'yaml'

module HP
  module Scalene
    class Config

      @@default_config = { :default_api_endpoint => 'agpa-ge1.csbu.hpl.hp.com' }

      def self.config_directory
        home_directory + "/.scalene/"
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
        write_account account, credentials
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
    
    end
  end
end
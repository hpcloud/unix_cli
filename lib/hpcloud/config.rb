require 'yaml'

module HPCloud
  class Config

    def self.config_directory
      home_directory + "/.hpcloud/"
    end
    
    def self.home_directory
      @@home_dir ||= ENV['HOME']
    end
    
    def self.home_directory=(dir)
      @@home_dir = dir # allow overload for testing
    end
    
    def self.accounts_directory
      config_directory + 'accounts/'
    end
    
    def self.update_credentials(account, credentials)
      ensure_config_exists
      write_account account, credentials
    end
    
    # Note: May want to port some of this to Thor's native actions eventually?
    def self.ensure_config_exists
      Dir.mkdir(config_directory) unless Dir.exists?(config_directory)
      Dir.mkdir(accounts_directory) unless Dir.exists?(accounts_directory)
      # TODO: write default config file if not present
    end
    
    def self.write_account(account_name, credentials)
      contents = {:credentials => credentials}
      File.open("#{accounts_directory}#{account_name.to_s.downcase.gsub(' ', '_')}", 'w') do |file|
        file.write contents.to_yaml
      end
    end
    
  end
end
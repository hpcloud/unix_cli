
RSpec.configure do |config|
  
  # Setup a temporary home directory for config file use
  def setup_temp_home_directory
    HP::Cloud::Config.home_directory = File.expand_path(File.dirname(__FILE__) + '/../tmp/home')
    Dir.mkdir(HP::Cloud::Config.home_directory) unless File.directory?(HP::Cloud::Config.home_directory)
  end
  
  def reset_config_home_directory
    HP::Cloud::Config.reset_home_directory
  end
  
  def remove_config_directory
    FileUtils.rm_rf(HP::Cloud::Config.config_directory)
  end
  
  def remove_account_files
    FileUtils.rm_rf(HP::Cloud::Config.accounts_directory + "*")
  end
  
end
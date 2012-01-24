
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

  def setup_account_file(account)
    # create account file
    File.open(HP::Cloud::Config.accounts_directory + account.to_s, 'w') do |file|
      file.write(read_account_file(account.to_s))
    end
    credentials = {:account_id => 'foo1', :secret_key => 'bar1', :auth_uri => 'http://192.168.1.1:9999/v2.0', :tenant_id => '222222'}
    HP::Cloud::Config.update_credentials(account, credentials)
  end

  def reset_account_settings(account)
    # reset account settings from fixture
    File.open(HP::Cloud::Config.accounts_directory + account.to_s, 'w') do |file|
      file.write(read_account_file(account.to_s))
    end
  end
end

RSpec.configure do |config|
  
  # Setup a temporary home directory for config file use
  def setup_temp_home_directory
    HP::Scalene::Config.home_directory = File.expand_path(File.dirname(__FILE__) + '/../tmp/home')
    Dir.mkdir(HP::Scalene::Config.home_directory) unless File.directory?(HP::Scalene::Config.home_directory)
  end
  
end